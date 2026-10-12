-- 1. Vérouillage : sans politique, plus aucun accès via l'API
ALTER TABLE public.organisations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.profils ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tickets ENABLE ROW LEVEL SECURITY;
-- 2. Organisation de l'utilisateur connecté
CREATE FUNCTION public.get_user_org_id()
RETURNS UUID
LANGUAGE SQL
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
    SELECT organisation_id FROM public.profils WHERE id = auth.uid()
$$;
-- 3. Lecture : uniquement les tickets de son organisation
CREATE POLICY "lecture_tickets_organisation" ON public.tickets
FOR SELECT TO authenticated
USING (
    organisation_id = (SELECT public.get_user_org_id())
);
-- 3. Création : auteur = soi-même ET  organisation = la sienne
CREATE POLICY "insterion_tickets_organisation" ON public.tickets
FOR INSERT TO authenticated
WITH CHECK (
    cree_par = (SELECT auth.uid())
    AND organisation_id = (SELECT public.get_user_org_id())
);    


