# Move Smart – Member 1 Report Draft

## Problem Statement
Daily commuters in Kigali, especially workers and students, face long, unmanaged waiting times at bus stops because boarding is still handled by physical queues and first-come, first-served access. Even with digital fare payment (Tap & Go), passengers do not have a guaranteed seat or predictable boarding time. This creates time poverty, lateness, and stress.

## Hypothesis Statement
If commuters can use a mobile app to reserve a guaranteed seat on a scheduled city bus trip before arriving at the station, then uncertainty, queue time, and commuter stress will decrease, and punctuality for work and school will improve.

## Literature Review (Short Draft)
Public transport studies and city reports consistently highlight a reliability gap in Kigali’s bus experience: payment is digitized, but boarding and demand management are not. This mismatch keeps the system in a queue-heavy model during peak periods.

1. **Capacity and accessibility limitations**: Prior transport assessments show a significant mismatch between demand and available service, reducing practical job accessibility by public transport within one hour.
2. **Observed queue burden**: Recent station-level observations (e.g., major hubs) report persistent waiting times of 45–60+ minutes during peak periods.
3. **Digital payment is not digital reservation**: Tap & Go improves fare handling but does not allocate seats or provide boarding guarantees.
4. **Operational model constraints**: Reform reviews describe legacy fill-and-go operating patterns that increase uncertainty and waiting when demand spikes.
5. **Need for scheduled demand management**: Research and policy recommendations support introducing schedule-based reservation and predictable dispatching to improve passenger experience.
6. **Affordability gap in alternatives**: Ride-hailing offers predictability but at a higher daily cost than mass transit, leaving room for an affordable booking-first bus product.

### Implication for Move Smart
Move Smart directly targets the identified system gap by combining identity, booking intent, and guaranteed trip access in one flow. For Member 1 scope, robust identity/authentication is foundational because every reservation, cancellation, and seat guarantee depends on trusted user state.

## Member 1 Technical Scope (Implemented)
- Entry flow screens: Welcome, Login, Signup
- Global auth state handling (logged-in vs logged-out)
- Email/Password auth flow
- Google and Apple sign-in integration hooks
- Users collection sync (Firestore) in auth datasource
- SharedPreferences persistence for:
  - session token/user info
  - language preference
  - dark mode preference
- Unit testing already available for email/password validation in validators tests
