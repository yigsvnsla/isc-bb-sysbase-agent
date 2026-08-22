import 'zone.js';
import 'zone.js/testing';
import { afterEach } from 'vitest';
import { getTestBed } from '@angular/core/testing';
import {
  BrowserDynamicTestingModule,
  platformBrowserDynamicTesting,
} from '@angular/platform-browser-dynamic/testing';

getTestBed().initTestEnvironment(
  BrowserDynamicTestingModule,
  platformBrowserDynamicTesting()
);

// Vitest no resetea el TestBed entre tests como sí lo hace Jasmine/Karma —
// sin esto, un spec nuevo que no reconfigure el TestBed explícitamente
// arrastra el estado (providers/componentes) del spec anterior.
afterEach(() => {
  getTestBed().resetTestingModule();
});
