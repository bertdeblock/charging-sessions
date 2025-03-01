import Route from '@ember/routing/route';
import type RouterService from '@ember/routing/router-service';
import { service } from '@ember/service';

export default class SessionsIndexRoute extends Route {
  @service declare router: RouterService;

  beforeModel(): void {
    this.router.transitionTo('sessions.new');
  }
}
