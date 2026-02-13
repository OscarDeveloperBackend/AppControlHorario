# Control Horario / Asistencia MVP

## Descripción
Proyecto Sprint 0: MVP de control de horario y asistencia.  
Incluye autenticación con Supabase, registro de jornada (iniciar, pausar, finalizar) y listado de historial.

## Stack
- React + TypeScript
- TailwindCSS
- Supabase (Auth + DB)

## Funcionalidades mínimas
- Signup + Login (Supabase Auth)
- Registro de jornada: iniciar, pausar, finalizar
- Historial de jornadas del usuario
- Persistencia en Supabase (no localStorage)

## Definition of Done (DoD)
- Funciona en navegador sin errores
- Conectado a Supabase real
- Cumple criterios del Product Owner
- Integrado a `main` mediante Pull Request
- Documentado en README
- Evidencia de debugging en `/docs/debug-log.md`

## Reglas de GitHub
- Repositorio único por equipo
- Ramas: `main` + `feature/*`
- Prohibido trabajar directo en `main`
- Mínimo 3 Pull Requests revisados
- Commits claros y descriptivos

## Instalación
```bash
npm install
npm run dev