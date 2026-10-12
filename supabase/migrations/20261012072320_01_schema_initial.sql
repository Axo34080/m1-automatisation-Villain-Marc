-- TP 2 : schéma initial du projet fil rouge (tenants, membres, tickets)

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Tenants
CREATE TABLE public.organisations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nom VARCHAR NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

-- Membres d'organisations (1 profil = 1 compte auth)
CREATE TABLE public.profils (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    organisation_id UUID NOT NULL REFERENCES public.organisations(id) ON DELETE RESTRICT,
    role VARCHAR(30) NOT NULL
        CHECK (role IN ('admin', 'tech', 'client')),
    nom_complet VARCHAR NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

CREATE INDEX idx_profils_organisation_id ON public.profils(organisation_id);

-- Cœur métier
CREATE TABLE public.tickets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organisation_id UUID NOT NULL REFERENCES public.organisations(id) ON DELETE CASCADE,
    cree_par UUID NOT NULL REFERENCES public.profils(id) ON DELETE RESTRICT,
    titre VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    statut VARCHAR(30) NOT NULL DEFAULT 'nouveau'
        CHECK (statut IN ('nouveau', 'en_cours', 'resolu', 'ferme')),
    priorite VARCHAR(30) NOT NULL DEFAULT 'normale'
        CHECK (priorite IN ('basse', 'normale', 'haute', 'critique')),
    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT TIMEZONE('utc', NOW())
);

CREATE INDEX idx_tickets_organisation_id ON public.tickets(organisation_id);
CREATE INDEX idx_tickets_statut ON public.tickets(statut);
CREATE INDEX idx_tickets_cree_par ON public.tickets(cree_par);