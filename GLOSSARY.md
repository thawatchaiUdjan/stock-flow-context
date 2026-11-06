# stock-flow

The shared vocabulary of stock-flow, a small inventory and order system for one shop. All three repos use these terms.

## Language

### Users & access

**Shop**:
The one business a stock-flow system serves.
_Avoid_: Store, tenant, organization

**User**:
A person who can log in to the system. Every User has exactly one Role.
_Avoid_: Account, member

**Role**:
The level of a User, which sets what that User may reach.
_Avoid_: Permission, user type

**Active**:
The status of a User who may log in.
_Avoid_: Enabled

**Inactive**:
The status of a User who may no longer log in. The User still exists.
_Avoid_: Disabled, deactivated, deleted

**Owner**:
The Role of the Shop's owner: the highest Role, held by exactly one User, the first one in the system. Not the requirements owner, who decides this project's requirements.
_Avoid_: Super-admin

**Admin**:
The Role of a person who helps run the Shop, with everything the Owner has except managing Users.
_Avoid_: Manager

**Staff**:
The Role of a person who works in the Shop day to day.
_Avoid_: Employee, general user

**Setup link**:
A one-time link through which a person sets their own password.
_Avoid_: Invite link, reset link, temporary password

**Login log**:
The permanent list of logins, failed logins and logouts.
_Avoid_: Audit log, login history
