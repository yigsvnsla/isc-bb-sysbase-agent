/**
 * Validación del flujo de navegación COBOL → Angular (end-to-end sin browser).
 * Carga pantalla -> flujo CALL (output navigate) -> carga otra pantalla.
 * SCREENS_TOKEN inyectado con pantallas fake (templates inline) para aislar el
 * mecanismo del viewer (outputs + paramMap reactivo).
 */
import { Component, EventEmitter, Output, type Type } from '@angular/core';
import { TestBed } from '@angular/core/testing';
import { RouterTestingHarness } from '@angular/router/testing';
import { provideRouter } from '@angular/router';
import { App } from './app';
import { routes } from './app.routes';
import { SCREENS_TOKEN } from './screens.token';

@Component({
  selector: 'isc-fake-actbal00',
  standalone: true,
  template: '<h3>ACTBAL00</h3><button (click)="go()">ACTINQ00</button>',
})
class FakeActbal00 {
  @Output() navigate = new EventEmitter<string>();
  go(): void {
    this.navigate.emit('ACTINQ00');
  }
}

@Component({
  selector: 'isc-fake-actinq00',
  standalone: true,
  template: '<h3>ACTINQ00</h3>',
})
class FakeActinq00 {}

@Component({
  selector: 'isc-fake-actstm00',
  standalone: true,
  template: '<h3>ACTSTM00</h3><button (click)="back()">Volver</button>',
})
class FakeActstm00 {
  @Output() navigate = new EventEmitter<string>();
  back(): void {
    this.navigate.emit('ACTBAL00');
  }
}

const FAKES: Record<string, Type<unknown>> = {
  actbal00: FakeActbal00,
  actinq00: FakeActinq00,
  actstm00: FakeActstm00,
};

async function configure(): Promise<void> {
  sessionStorage.setItem('isc-user', 'demo');
  TestBed.configureTestingModule({
    imports: [App],
    providers: [provideRouter(routes), { provide: SCREENS_TOKEN, useValue: FAKES }],
  });
  await TestBed.compileComponents();
}

describe('flujo de navegación COBOL (viewer)', () => {
  it('navegación directa carga la pantalla correcta', async () => {
    await configure();
    const harness = await RouterTestingHarness.create('/screens/actbal00');
    expect(harness.routeNativeElement!.querySelector('isc-fake-actbal00')).toBeTruthy();
  });

  it('click en flujo CALL navega a la pantalla destino', async () => {
    await configure();
    const harness = await RouterTestingHarness.create('/screens/actbal00');
    const el = harness.routeNativeElement!;
    expect(el.querySelector('isc-fake-actbal00')).toBeTruthy();
    const btn = [...el.querySelectorAll('button')].find((b) => b.textContent?.trim() === 'ACTINQ00');
    expect(btn).toBeTruthy();
    (btn as HTMLElement).click();
    await harness.detectChanges();
    await harness.fixture.whenStable();
    expect(el.querySelector('isc-fake-actinq00')).toBeTruthy();
  });

  it('flujo inverso: ACTSTM00 -> ACTBAL00', async () => {
    await configure();
    const harness = await RouterTestingHarness.create('/screens/actstm00');
    const el = harness.routeNativeElement!;
    const btn = [...el.querySelectorAll('button')].find((b) => b.textContent?.trim() === 'Volver');
    (btn as HTMLElement).click();
    await harness.detectChanges();
    await harness.fixture.whenStable();
    expect(el.querySelector('isc-fake-actbal00')).toBeTruthy();
  });

  it('cambio directo de URL entre pantallas re-renderiza', async () => {
    await configure();
    const harness = await RouterTestingHarness.create('/screens/actbal00');
    await harness.navigateByUrl('/screens/actinq00');
    expect(harness.routeNativeElement!.querySelector('isc-fake-actinq00')).toBeTruthy();
  });

  it('navTarget sin pantalla registrada muestra fallback en vez de quedar en blanco', async () => {
    await configure();
    const harness = await RouterTestingHarness.create('/screens/comdate');
    const el = harness.routeNativeElement!;
    expect(el.querySelector('[role="alert"]')?.textContent).toContain('comdate');
  });

  it('recuperarse de un navTarget faltante al navegar a una pantalla válida', async () => {
    await configure();
    const harness = await RouterTestingHarness.create('/screens/comdate');
    await harness.navigateByUrl('/screens/actbal00');
    const el = harness.routeNativeElement!;
    expect(el.querySelector('isc-fake-actbal00')).toBeTruthy();
    expect(el.querySelector('[role="alert"]')).toBeFalsy();
  });
});
