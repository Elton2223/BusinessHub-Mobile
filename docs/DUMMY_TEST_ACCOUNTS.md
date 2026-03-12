# Dummy test accounts (employer vs worker)

When **USE_MOCK_DATA** is `true` (default in development), you can sign in with these accounts to test the full flow between an **employer** and a **worker/client**.

## Accounts

| Role     | Email                     | Password |
|----------|---------------------------|----------|
| Employer | `employer@businesshub.com` | `Test123!` |
| Worker   | `worker@businesshub.com`   | `Test123!` |

## How to test

1. **Login as employer**  
   Email: `employer@businesshub.com`, Password: `Test123!`

2. **Create a hub**  
   Go to Hubs → “Add a hub”, fill in details. Your hub will **not** appear in your own Hubs list; it appears for others.

3. **Logout** and **login as worker**  
   Email: `worker@businesshub.com`, Password: `Test123!`

4. **Apply to the hub**  
   Open Hubs → find the hub created by the employer → open it → “Send application”.

5. **Logout** and **login as employer** again.

6. **Accept the application**  
   Open Notifications → tap the “New application” notification → Accept (or Decline with a reason).

7. Continue the flow (worker arrives, confirm arrival, complete work, payment, ratings) as in the app.

## Notes

- These logins only work when mock data is enabled (e.g. `USE_MOCK_DATA=true` in `.env` or default).
- Your own hubs are hidden from the main Hubs list; use **My Hubs** to see and manage them.
- You cannot apply to your own hub; the Apply section is hidden for hub owners.
