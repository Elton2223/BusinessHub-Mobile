# BusinessHub Mobile – API contract for backend

This document describes the API endpoints the mobile app expects from the backend (`BusinessHubBackend/business-hub-backend`). The app currently uses **dummy data** when `USE_MOCK_DATA=true` (default). When you switch to the real API, implement or align these endpoints so the app can be configured with `USE_MOCK_DATA=false` and the same flows work.

---

## 1. Hubs / Jobs (existing)

- **GET** `/jobhub` – List all jobhubs (or support query params for filters).
- **GET** `/jobhub?filter[where][jobStatus]=1` – Available hubs.
- **GET** `/jobhub?filter[where][jobStatus]=2` – Active (in progress) hubs.
- **GET** `/jobhub/:id` – Single hub by ID.
- **GET** `/jobhub?filter[where][category]=:category` – By category.
- **POST** `/jobhub` – Create hub (body: same as `JobhubModel.toJson()`).
- **PATCH** `/jobhub/:id` – Update hub (e.g. set `jobStatus: 2` when application accepted).
- **DELETE** `/jobhub/:id` – Delete hub.

**Optional (for location filter):**

- **GET** `/jobhub?lat=:lat&lng=:lng&radiusKm=:km` – Hubs within radius (km) of user. If not supported, app will use `GET /jobhub` and filter client-side when using real API.

---

## 2. Applications

- **POST** `/applications` (or `/jobhub/:id/applications`)  
  Body: `{ "hubId": number, "applicantUserId": string, "message": string? }`  
  Returns: created application (id, hubId, applicantUserId, status: "pending", createdAt, etc.).

- **GET** `/applications?hubId=:id` – Applications for a hub (for hub owner to accept/reject).
- **GET** `/applications?applicantUserId=:id` – Applications by a user (my applications).
- **GET** `/applications/:id` – Single application.
- **PATCH** `/applications/:id`  
  Body: `{ "status": "accepted" | "rejected", "declineReason"?: "string" }`  
  When status is `"rejected"`, the app sends `declineReason` (required in UI) so the applicant can rectify their profile. Store it on the application and include it in the rejection notification body.  
  When status is "accepted", backend should set hub’s `jobStatus` to 2 (in progress) and create a notification for the applicant.

---

## 3. Notifications

- **GET** `/notifications?toUserId=:id` – Notifications for user (ordered by createdAt desc).
- **GET** `/notifications/count?toUserId=:id&read=false` – Unread count (optional).
- **PATCH** `/notifications/:id` – Body: `{ "read": true }`.

**Creation (usually done by backend on events):**

- When an application is **created** → create notification for hub owner:  
  `type: "application_received"`, `toUserId: hub owner`, `relatedHubId`, `relatedApplicationId`, `fromUserId: applicant`, title/body as needed.
- When an application is **accepted or rejected** → create notification for applicant:  
  `type: "application_accepted"` or `"application_rejected"`, `toUserId: applicant`, `relatedApplicationId`, `relatedHubId`, title/body. For rejections, include the **decline reason** in the body so the applicant can improve their profile.
- When a **work session** worker arrives (within 50m):  
  `type: "worker_arrived"`, `toUserId: employer`, `relatedHubId`, `relatedSessionId` (optional), title e.g. "Worker has arrived", body e.g. "Worker is within 50m. Confirm their arrival."
- When worker **leaves the job area** (outside 50m) while in progress:  
  `type: "worker_left_area"`, `toUserId: employer`, `relatedHubId`, body e.g. "Worker left the 50m area. Still working?"
- When work is **completed (full)**:  
  `type: "session_completed"`, `toUserId: worker`, `relatedHubId`, body e.g. "Work marked completed. Employer will send payment."
- When **employer submits payment proof**:  
  `type: "payment_sent"`, `toUserId: worker`, `relatedHubId`, body e.g. "Employer submitted payment proof. Confirm receipt."

---

## 4. Ratings

- **POST** `/ratings`  
  Body: `{ "hubId": number, "fromUserId": string, "toUserId": string, "rating": 1–5, "comment": string?, "role": "as_employer" | "as_worker" }`.

- **GET** `/ratings?toUserId=:id` – Ratings received by a user (for profile/display).

---

## 5. Work sessions

Work sessions track an accepted application from “waiting for worker to arrive” through “work in progress” to “completed” (full or for today). Used for 50m location check-in and completion flow.

**Create when employer accepts an application:**

- **POST** `/work-sessions` (or create automatically when `PATCH /applications/:id` sets `status: "accepted"`)  
  Body: `{ "hubId": number, "applicationId": string, "workerId": string, "employerId": string }`  
  Returns: created session with `id`, `status: "pending_arrival"`.  
  Backend should create this when an application is accepted (or expose POST for the app to call).

**Read:**

- **GET** `/work-sessions?hubId=:id&employerId=:id` – Session for a hub (employer view). Return at most one active session for that hub and employer.
- **GET** `/work-sessions?workerId=:id` – Active sessions for a worker (status in `pending_arrival`, `arrived_waiting_confirm`, `in_progress`, `completed_today`).
- **GET** `/work-sessions/:id` – Single session by ID.

**Update status / events:**

- **PATCH** `/work-sessions/:id` – Partial update. The app sends:
  - **Worker arrived (within 50m):**  
    Body: `{ "status": "arrived_waiting_confirm", "workerArrivedAt": "<ISO8601>", "lastWorkerLat": number, "lastWorkerLng": number }`  
    Backend should create a notification to the employer: worker has arrived.
  - **Employer confirmed arrival:**  
    Body: `{ "status": "in_progress", "employerConfirmedArrivalAt": "<ISO8601>" }`
  - **Worker left area (outside 50m):**  
    Body: `{ "workerLeftAreaAt": "<ISO8601>" }`  
    Backend should create a notification to the employer (e.g. “Worker left the area – still working?”).
  - **Complete work:**  
    Body: `{ "status": "completed_full" | "completed_today", "completedAt": "<ISO8601>", "completionType": "full" | "today" }`  
    If `completionType` is `"full"`, backend should set the hub’s `jobStatus` to 3 (completed) and notify the worker that work is completed and payment can follow.

**Suggested session model fields:**

- `id`, `hubId`, `applicationId`, `workerId`, `employerId`
- `status`: `pending_arrival` | `arrived_waiting_confirm` | `in_progress` | `completed_today` | `completed_full`
- `workerArrivedAt`, `employerConfirmedArrivalAt`, `completedAt` (ISO8601)
- `completionType`: `"full"` | `"today"`
- `lastWorkerLat`, `lastWorkerLng`, `workerLeftAreaAt`, `workerStillWorking` (optional)

---

## 6. Payment proofs

Employer submits payment proof; worker confirms with their proof. Both must be present for payment to be considered complete. After that, the app adds the job to the worker’s history and prompts ratings.

**Submit employer proof (after work completed full):**

- **POST** `/payment-proofs`  
  Body: `{ "hubId": number, "sessionId": string, "amount": number, "employerProofDescription": string }`  
  Returns: created or updated payment proof (id, hubId, sessionId, amount, employerProofDescription, employerSubmittedAt).  
  Backend should create a notification to the worker: payment proof submitted, please confirm.

**Submit client (worker) confirmation:**

- **PATCH** `/payment-proofs/:id` or **POST** `/payment-proofs/:id/confirm`  
  Body: `{ "clientProofDescription": string }`  
  Or: **POST** `/payment-proofs` with `sessionId` and `clientProofDescription` to update existing.  
  Returns: updated payment proof with `clientConfirmedAt`.  
  When both employer and client proof are present, backend may create job history entry and/or trigger rating prompts (or the app creates history client-side from the proof response).

**Read:**

- **GET** `/payment-proofs?sessionId=:id` – Payment proof for a work session (single).
- **GET** `/payment-proofs?hubId=:id` – Payment proof for a hub (single).

**Suggested payment proof model fields:**

- `id`, `hubId`, `sessionId`, `amount`
- `employerProofDescription`, `employerSubmittedAt` (ISO8601)
- `clientProofDescription`, `clientConfirmedAt` (ISO8601)

---

## 7. Job history

Completed jobs for the worker (after payment is confirmed). Used for “Job history” screen and “Rate employer” after completion.

**List for worker:**

- **GET** `/job-history?workerId=:id` – List of completed job history entries for the worker, ordered by `completedAt` desc.  
  Returns array of: `id`, `hubId`, `hubTitle`, `employerId`, `workerId`, `paymentAmount`, `completedAt`, `paymentReceived`, `ratingGiven`.

**Create (when payment proof is complete):**

- Backend can create a job history entry when a payment proof gets `clientConfirmedAt` set (or expose **POST** `/job-history` for the app to call).  
  Body: `{ "hubId", "hubTitle", "employerId", "workerId", "paymentAmount" }`.  
  Defaults: `paymentReceived: true`, `ratingGiven: false`.

**Mark rating given:**

- **PATCH** `/job-history/:id`  
  Body: `{ "ratingGiven": true }`  
  So the app can hide “Rate employer” after the worker has rated.

**Suggested job history model fields:**

- `id`, `hubId`, `hubTitle`, `employerId`, `workerId`
- `paymentAmount`, `completedAt` (ISO8601)
- `paymentReceived` (boolean), `ratingGiven` (boolean)

---

## 8. User / Auth (existing)

- Login, register, profile, etc. as already implemented.  
- For “applicant profile & documents” in the app, the backend can expose:
  - **GET** `/users/:id` or `/user-management/:id` – Public profile (name, email, city, documents) for viewing by hub owner when reviewing an application.

---

## 9. Filter settings (optional)

- Filter settings (location range, area names, categories, “ongoing only”) are stored **locally** in the app (SharedPreferences).  
- Optional: **GET/PATCH** `/user/preferences` or `/users/:id/preferences` to sync filter settings across devices.

---

## Summary table

| Area           | Method | Endpoint (example)           | Notes |
|----------------|--------|------------------------------|--------|
| Hubs           | GET    | /jobhub                      | List; support filters if possible. |
| Hubs           | GET    | /jobhub/:id                  | Single hub. |
| Hubs           | POST   | /jobhub                      | Create. |
| Hubs           | PATCH  | /jobhub/:id                  | Update (e.g. jobStatus). |
| Applications   | POST   | /applications                | Create application. |
| Applications   | GET    | /applications?hubId=         | For hub owner. |
| Applications   | GET    | /applications?applicantUserId= | My applications. |
| Applications   | PATCH  | /applications/:id            | Accept/reject. |
| Notifications  | GET    | /notifications?toUserId=    | List for user. |
| Notifications  | PATCH  | /notifications/:id          | Mark read. |
| Ratings        | POST   | /ratings                     | Submit rating. |
| Ratings        | GET    | /ratings?toUserId=           | Ratings for user. |
| Work sessions  | POST   | /work-sessions               | Create when application accepted. |
| Work sessions  | GET    | /work-sessions?hubId=&employerId= | Session for hub (employer). |
| Work sessions  | GET    | /work-sessions?workerId=     | Active sessions for worker. |
| Work sessions  | GET    | /work-sessions/:id           | Single session. |
| Work sessions  | PATCH  | /work-sessions/:id           | Update status, arrival, completion. |
| Payment proofs | POST   | /payment-proofs              | Submit employer proof. |
| Payment proofs | PATCH  | /payment-proofs/:id or /confirm | Submit client confirmation. |
| Payment proofs | GET    | /payment-proofs?sessionId=   | Proof for session. |
| Job history    | GET    | /job-history?workerId=       | List for worker. |
| Job history    | POST   | /job-history                 | Create when payment complete (optional). |
| Job history    | PATCH  | /job-history/:id             | Mark ratingGiven. |

---

## Switching from dummy to real API

1. In the mobile project, set `USE_MOCK_DATA=false` in `.env` (or set the env var your app reads).
2. Ensure `ApiConfig.baseUrl` (or env) points to your backend.
3. Implement the endpoints above in the backend. The mobile app’s services have `// TODO` or conditional `_useMock` branches where to call the real API:
   - **Hubs:** `HubRepository`
   - **Applications:** `ApplicationService`
   - **Notifications:** `NotificationService`
   - **Ratings:** `RatingService`
   - **Work sessions:** `WorkSessionService` (create, get by hub/worker, report arrival, confirm arrival, report left area, complete work)
   - **Payment proofs:** `PaymentProofService` (submit employer proof, submit client proof, get by session)
   - **Job history:** `JobHistoryService` (get for worker, mark rating given)
