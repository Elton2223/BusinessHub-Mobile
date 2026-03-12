# BusinessHub Mobile – Flow verification

This document checks the app against the full flow you described. Each requirement is marked **MET**, **PARTIAL**, or **GAP**, with code references where relevant.

---

## 1. Hubs: browse, view, apply, notify owner, accept/reject, view applicant

| Requirement | Status | Notes |
|-------------|--------|--------|
| User clicks Hubs and sees hubs/jobs in nearest area | **MET** | `hub_list.dart`: loads via `HubRepository.getJobhubsNear(lat, lng, locationRangeKm)` when user has lat/lng and filter has range; else `getAllJobhubs()`. `DummyHubData.getHubsNear()` uses haversine. |
| View each hub: requirements, pricing | **MET** | `hub_detail_page.dart`: shows title, category, address, requirements, description, payment (amount + type). |
| User can apply to hub | **MET** | `hub_detail_page.dart` `_apply()`: `ApplicationService.apply()` then `NotificationService.notifyApplicationReceived()` to hub owner. |
| Notification sent to user who created the hub | **MET** | `notifyApplicationReceived(toUserId: hub.registerId, ...)`; dummy creates `application_received` notification. |
| Hub owner can view notification and accept or reject | **MET** | `notifications_screen.dart`: list for `toUserId`; tap `application_received` opens `ApplicationDetailPage` with Accept/Decline. `_respond('accepted' \| 'rejected')` calls `ApplicationService.respondToApplication()`. |
| Owner can check documents and profile of applicant | **PARTIAL** | `ApplicationDetailPage` has “Applicant profile & documents”: name, email, city from dummy user. Documents line: *“Documents (e.g. ID, resume) can be viewed or uploaded when connected to the backend.”* Real document view/upload depends on backend. |

---

## 2. Post Hubs/jobs; appear for others nearby

| Requirement | Status | Notes |
|-------------|--------|--------|
| User can post Hubs/jobs | **MET** | Hub list “Add a hub” opens `_showAddHubDialog`; creates via `HubRepository.createJobhub(hub)` with `registerId: user?.id`. |
| Posted jobs appear under Hub for other users | **MET** | Dummy: `DummyHubData.addHub()` adds to same `_hubs` list; `getHubs()` / `getHubsNear()` return all. So new hubs appear for everyone (and in radius when location filter applies). |
| New hubs use poster’s location for “nearby” | **MET** | Add-hub dialog sets `latitude`/`longitude` from `user?.latitude`/`user?.longitude`. |

---

## 3. Filter settings

| Requirement | Status | Notes |
|-------------|--------|--------|
| Filter by location range | **MET** | `hub_filter_settings_screen.dart`: “Location range (km)” slider (1–200). `hub_list.dart` uses `_filterSettings.locationRangeKm` in `getJobhubsNear()`. |
| Filter by names of area | **MET** | Hub filter screen: “Filter by area (city)” with preset cities (e.g. Johannesburg, Cape Town). `hub_list.dart` filters by `_filterSettings.areaNames` (hub.city). |
| Filter by hubs/jobs available | **MET** | Hub filter: “Only show available hubs”. Hub list: “Available” tab and `_filterSettings.availableOnly` (jobStatus == 1). |
| Filter by ongoing hubs | **MET** | Hub filter: “Only show ongoing hubs”. Hub list: “Ongoing” tab and `_filterSettings.ongoingOnly` (in progress). |
| Other filterings | **MET** | Category chips in hub filter; hub list applies `_filterSettings.categories`. Settings → Hub filters persists via `FilterSettingsService`. |

---

## 4. Ratings (both sides)

| Requirement | Status | Notes |
|-------------|--------|--------|
| User can rate the work / rate the person they worked for | **MET** | Hub detail when hub is completed and user is the other party: “Rate this job” with “Rate worker” or “Rate employer”. `showRateUserDialog(..., role: as_employer \| as_worker)`. |
| Other party can rate the worker they accepted | **MET** | Employer rates worker via same dialog with `role: 'as_employer'`. Worker rates employer with `role: 'as_worker'` (from hub detail or after payment confirm). |
| Rating stored and used | **MET** | `RatingService.submitRating()`; dummy `DummyHubData.addRating()`. Job history “Rate employer” opens rate dialog; `JobHistoryService.markRatingGiven()`. |

---

## 5. Work session after accept (50m, arrival, complete, payment, history)

| Requirement | Status | Notes |
|-------------|--------|--------|
| On accept, system tracks worker location (50m) | **MET** | `notifications_screen.dart` on accept: `WorkSessionService.createSessionWhenAccepted(...)`. Worker: `active_work_session_screen.dart` polls location every 10s; `LocationTrackingService.workRadiusMeters` = 50. |
| Notify employer when worker arrives in radius | **MET** | When `dist <= 50m`, `WorkSessionService.reportWorkerArrived()`; dummy sets session to `arrived_waiting_confirm` and `addNotificationForEmployer('worker_arrived', ...)`. |
| Employer can confirm worker arrival | **MET** | Hub detail shows “Worker has arrived” and “Confirm arrival”; `_confirmArrival()` → `WorkSessionService.confirmWorkerArrival()`. |
| Button to complete work: “Complete work” / “Complete work for today” | **MET** | Hub detail “Complete work” opens dialog with “Complete work” (full) and “Complete work for today”. `_completeWork('full' \| 'today')`; full sets hub jobStatus to 3. |
| Track when worker leaves area; notify (still working or not) | **MET** | `_checkLocation()` when `dist > 50m` and in progress calls `reportWorkerLeftArea()`. Notification: “Worker left the area (50m). Are they still working or finished for now?”. Only one notification per leave (guard: `s.workerLeftAreaAt == null`). Employer can use “Complete work for today” if not still working. |
| When work done, employer can send agreed payment | **MET** | After “Complete work” (full), hub detail shows “Send payment”; employer submits proof (description). `PaymentProofService.submitEmployerProof()`. |
| Payment proof from employer and client for security | **MET** | Employer submits proof; worker sees “Confirm payment received” and submits their proof. `PaymentProofModel`: both `employerSubmittedAt` and `clientConfirmedAt` required for completion. |
| After payment, ratings and job complete history for worker | **MET** | When worker confirms payment, dummy adds `JobHistoryModel` via `addJobHistory()`. Worker gets rate dialog (employer). Job history screen lists completed jobs and “Rate employer”. Hub detail shows “Rate worker” for employer when completed. |

---

## 6. Notifications and UX

| Item | Status | Notes |
|------|--------|--------|
| Unread badge on Notifications | **MET** | Home bottom nav uses `_unreadNotificationCount`; badge when > 0. |
| Active work badge in drawer | **MET** | `_activeWorkCount` from `getActiveSessionsForWorker`; drawer “Active work” shows trailing count when > 0. |
| Success feedback (snackbar + checkmark) | **MET** | `showSuccessSnackBar()` used for confirm arrival, complete work, payment submitted, payment confirmed, hub added. |
| Empty states with one primary action | **MET** | Hub list: “Post a hub”; My Hubs: “Go to Hubs”; My Applications: “Browse Hubs”; Active work: “Browse Hubs”; Job history: “Browse Hubs”; Notifications: “Go to Hubs”. |

---

## 7. Gaps / partial behaviour

1. **Applicant documents**  
   Profile is shown (name, email, city). Document view/upload is placeholder text until backend supports it (e.g. GET user documents or profile with `identification_doc`).

2. **“Still working?” explicit action**  
   Employer is notified when worker leaves the area. There is no dedicated “Still working?” / “No” button; they use “Complete work” → “Complete work for today” to indicate work continues another day. Optional improvement: add a quick action on the notification or on hub detail: “Still working?” / “Finish for today”.

3. **Scheduled work times**  
   `WorkSessionModel` has `scheduledWorkStart` / `scheduledWorkEnd` but the app does not yet restrict “at work” or arrival to a time window. Optional: only consider worker “at work” when within 50m and within scheduled time.

4. **Backend vs dummy**  
   All of the above work with dummy data (`USE_MOCK_DATA=true`). Switching to the real API requires implementing the endpoints in `API_BACKEND_CONTRACT.md` and wiring services when `USE_MOCK_DATA=false`.

---

## Summary

- **Storyline 1 (Hubs, view, apply, notify, accept/reject, profile):** Met; documents are partial until backend.
- **Storyline 2 (Post hubs, appear nearby):** Met.
- **Storyline 3 (Filter settings):** Met (location range, area, available, ongoing, category).
- **Storyline 4 (Ratings both sides):** Met.
- **Storyline 5 (Work session, 50m, arrival, complete, payment, history):** Met; optional: explicit “Still working?” and scheduled work times.

The system abides by the flow you shared; the only intentional partial part is applicant documents until the backend supports them.
