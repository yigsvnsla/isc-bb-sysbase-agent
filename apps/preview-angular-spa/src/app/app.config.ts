import {
  ApplicationConfig,
  provideBrowserGlobalErrorListeners,
  provideZonelessChangeDetection,
} from '@angular/core';
import { provideRouter } from '@angular/router';
import { providePrimeNG } from 'primeng/config';

import { routes } from './app.routes';
import { iscPreset } from './theme';
import { SCREENS_TOKEN } from './screens.token';
import { SCREENS } from '../screens/registry';

export const appConfig: ApplicationConfig = {
  providers: [
    provideBrowserGlobalErrorListeners(),
    // zone.js nunca se carga en runtime (no está en polyfills de angular.json) — toda
    // la app ya está construida con signals + OnPush, así que zoneless es explícito
    // en vez de quedar como comportamiento implícito/no garantizado.
    provideZonelessChangeDetection(),
    provideRouter(routes),
    providePrimeNG({ theme: { preset: iscPreset, options: { darkModeSelector: false } } }),
    { provide: SCREENS_TOKEN, useValue: SCREENS },
  ]
};
