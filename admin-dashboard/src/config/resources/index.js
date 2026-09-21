import { propertiesResource } from './properties';
import { tenantsResource } from './tenants';
import { contractsResource } from './contracts';
import { ownersResource } from './owners';
import { usersResource } from './users';
import { paymentsResource } from './payments';
import { projectsResource } from './projects';
import { maintenanceRequestsResource } from './maintenanceRequests';
import { notificationsResource } from './notifications';
import { calendarEventsResource } from './calendarEvents';
import { tasksResource } from './tasks';
import { conversationsResource } from './conversations';
import { mobileRequestsResource } from './mobileRequests';
import { reportsResource } from './reports';

export const resources = {
  properties: propertiesResource,
  tenants: tenantsResource,
  contracts: contractsResource,
  owners: ownersResource,
  users: usersResource,
  payments: paymentsResource,
  projects: projectsResource,
  maintenance_requests: maintenanceRequestsResource,
  notifications: notificationsResource,
  calendar_events: calendarEventsResource,
  tasks: tasksResource,
  conversations: conversationsResource,
  mobile_requests: mobileRequestsResource,
  reports: reportsResource,
};
