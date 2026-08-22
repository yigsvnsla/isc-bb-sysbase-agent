import {
  ChangeDetectionStrategy,
  Component,
  ComponentRef,
  effect,
  inject,
  signal,
  viewChild,
  ViewContainerRef,
} from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { map } from 'rxjs';
import { toSignal } from '@angular/core/rxjs-interop';
import { SCREENS_TOKEN } from './screens.token';

/**
 * Carga la pantalla COBOL migrada en /screens/:id y encadena su flujo (CALL).
 * Instancia el componente manualmente (ViewContainerRef) para suscribirse a los
 * outputs `navigate` / `authenticated` — NgComponentOutlet NO propaga outputs.
 */
@Component({
  selector: 'app-screen-viewer',
  standalone: true,
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <ng-container #host></ng-container>
    @if (notFound(); as missing) {
      <div class="screen-not-found" role="alert">
        Pantalla "{{ missing }}" no disponible en este preview.
      </div>
    }
  `,
})
export class ScreenViewerComponent {
  private readonly router = inject(Router);
  private readonly route = inject(ActivatedRoute);
  private readonly host = viewChild.required('host', { read: ViewContainerRef });
  private readonly screens = inject(SCREENS_TOKEN);

  readonly id = toSignal(this.route.paramMap.pipe(map((p) => (p.get('id') ?? '').toLowerCase())));
  readonly notFound = signal<string | null>(null);

  private ref: ComponentRef<unknown> | null = null;
  private rendered = '';

  constructor() {
    effect(() => {
      const id = this.id();
      const vcr = this.host();
      if (!id || !vcr || id === this.rendered) return;
      this.rendered = id;
      if (!this.screens[id]) {
        this.ref?.destroy();
        this.ref = null;
        this.notFound.set(id);
        return;
      }
      this.notFound.set(null);
      this.render(id, vcr);
    });
  }

  private render(id: string, vcr: ViewContainerRef): void {
    this.ref?.destroy();
    this.ref = null;
    const comp = this.screens[id];
    if (!comp) return;
    this.ref = vcr.createComponent(comp);
    const inst = this.ref.instance as Partial<{ navigate: unknown; authenticated: unknown }>;
    const navigate = inst.navigate as { subscribe?: (fn: (t: string) => void) => void } | undefined;
    const authenticated = inst.authenticated as { subscribe?: (fn: () => void) => void } | undefined;
    navigate?.subscribe?.((t: string) => this.go(t));
    authenticated?.subscribe?.(() => this.go(''));
  }

  private go(target: string): void {
    if (!target) {
      void this.router.navigate(['/']);
      return;
    }
    if (this.screens[target.toLowerCase()]) void this.router.navigate(['/screens', target.toLowerCase()]);
  }

  ngOnDestroy(): void {
    this.ref?.destroy();
    this.ref = null;
  }
}
