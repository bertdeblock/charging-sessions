import Route from '@ember/routing/route';
import type RouterService from '@ember/routing/router-service';
import { service } from '@ember/service';
import { isAuth } from 'ev/auth';

export default class SessionsRoute extends Route {
  @service declare router: RouterService;

  beforeModel(): void {
    if (isAuth() === false) {
      this.router.transitionTo('index');
    }
  }
}
