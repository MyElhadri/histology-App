--
-- PostgreSQL database dump
--

\restrict ib9FN15BF8bRflxRzOoInmVoJm0Sys9MoNS4hZ7GZJN0XojPWqevcPTgQgf93Zr

-- Dumped from database version 15.19 (Debian 15.19-1.pgdg13+2)
-- Dumped by pg_dump version 15.19 (Debian 15.19-1.pgdg13+2)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: Choix; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Choix" (
    "Id" uuid NOT NULL,
    "QuestionId" uuid NOT NULL,
    "Texte" text NOT NULL,
    "EstCorrect" boolean NOT NULL
);


ALTER TABLE public."Choix" OWNER TO postgres;

--
-- Name: Organes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Organes" (
    "Id" uuid NOT NULL,
    "Nom" text NOT NULL,
    "UrlImage" text NOT NULL
);


ALTER TABLE public."Organes" OWNER TO postgres;

--
-- Name: Questions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Questions" (
    "Id" uuid NOT NULL,
    "TissuId" uuid NOT NULL,
    "Texte" text NOT NULL
);


ALTER TABLE public."Questions" OWNER TO postgres;

--
-- Name: ResultatsQCM; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."ResultatsQCM" (
    "Id" uuid NOT NULL,
    "UtilisateurId" uuid NOT NULL,
    "ScanId" uuid NOT NULL,
    "Note" integer NOT NULL,
    "DateTest" timestamp with time zone NOT NULL
);


ALTER TABLE public."ResultatsQCM" OWNER TO postgres;

--
-- Name: Scans; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Scans" (
    "Id" uuid NOT NULL,
    "UtilisateurId" uuid NOT NULL,
    "TissuId" uuid NOT NULL,
    "UrlImage" text NOT NULL,
    "ScoreConfiance" real NOT NULL,
    "DateScan" timestamp with time zone NOT NULL
);


ALTER TABLE public."Scans" OWNER TO postgres;

--
-- Name: TissuOrganes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."TissuOrganes" (
    "TissuId" uuid NOT NULL,
    "OrganeId" uuid NOT NULL
);


ALTER TABLE public."TissuOrganes" OWNER TO postgres;

--
-- Name: Tissus; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Tissus" (
    "Id" uuid NOT NULL,
    "Nom" text NOT NULL,
    "CodeLabelIa" text NOT NULL,
    "Description" text NOT NULL,
    "Fonctions" text NOT NULL
);


ALTER TABLE public."Tissus" OWNER TO postgres;

--
-- Name: Utilisateurs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Utilisateurs" (
    "Id" uuid NOT NULL,
    "Nom" text NOT NULL,
    "Prenom" text NOT NULL,
    "Email" text NOT NULL,
    "MotDePasseHash" text NOT NULL,
    "Role" text NOT NULL,
    "DateCreation" timestamp with time zone NOT NULL,
    "EstActif" boolean DEFAULT false NOT NULL,
    "Apogee" text,
    "GroupeTp" text
);


ALTER TABLE public."Utilisateurs" OWNER TO postgres;

--
-- Name: __EFMigrationsHistory; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."__EFMigrationsHistory" (
    "MigrationId" character varying(150) NOT NULL,
    "ProductVersion" character varying(32) NOT NULL
);


ALTER TABLE public."__EFMigrationsHistory" OWNER TO postgres;

--
-- Data for Name: Choix; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Choix" ("Id", "QuestionId", "Texte", "EstCorrect") FROM stdin;
37dd68d9-2653-402c-b80a-d730b30a0010	535cb570-f160-43dd-996b-592037922144	Plusieurs couches superposees avec desquamation superficielle	f
82a17249-ebe9-4e64-9809-93791963d090	535cb570-f160-43dd-996b-592037922144	Une seule assise de cellules reposant directement sur la membrane basale	t
a9dfa747-a6b5-4389-94b7-24f279220b53	535cb570-f160-43dd-996b-592037922144	Une absence totale de polarite cellulaire apico-basale	f
b76f236f-2578-4f56-af11-859637c7f82e	535cb570-f160-43dd-996b-592037922144	Une matrice extracellulaire tres abondante et vascularisee	f
0ac82776-1e25-4661-912c-4f294908ba70	3bfb19f4-df87-473e-8cf2-e90bae54d7df	Les cils vibratiles mobiles	f
4d908f4d-36a7-4a71-9cb8-97478b34ec05	3bfb19f4-df87-473e-8cf2-e90bae54d7df	Une epaisse couche de keratine anucleee	f
9cf29fda-e9ea-4507-ada2-522db75482b0	3bfb19f4-df87-473e-8cf2-e90bae54d7df	Des flagelles contractiles	f
d8870d09-30d4-49e6-85fd-2f3671c57425	3bfb19f4-df87-473e-8cf2-e90bae54d7df	Les microvillosites sous forme de plateau strie	t
6b66a8b2-d6b9-4793-bb6c-7e1fd89fd3fe	7f4286b6-d63f-414d-8c0b-23b97e20ca0e	L'adipocyte uniloculaire	f
9ead41e0-a8f3-4474-851f-5fa68d363198	7f4286b6-d63f-414d-8c0b-23b97e20ca0e	L'osteoclaste multinuclee	f
9eb7dcf6-2294-4a43-bf7a-83f183b3c6d8	7f4286b6-d63f-414d-8c0b-23b97e20ca0e	Le fibroblaste quiescent	f
db8a5d60-bc12-4632-8a63-2115212fc99a	7f4286b6-d63f-414d-8c0b-23b97e20ca0e	La cellule caliciforme secretant du mucus	t
1f813113-beab-4df8-8ba5-4c554d5b19db	d4c71fd5-b991-4b63-a400-581de16f4e93	Par des canaux lymphatiques perforants	f
71b20abf-d931-42cb-8103-33757938e890	d4c71fd5-b991-4b63-a400-581de16f4e93	Par diffusion passive et transport a partir des capillaires du chorion sous-jacent	t
7ddd4ceb-bd46-42ed-95b3-a196c366b0dd	d4c71fd5-b991-4b63-a400-581de16f4e93	Par autophagie exclusive des cellules basales	f
bc3ae862-8c3b-4ed9-b9a9-e872c88fbfa6	d4c71fd5-b991-4b63-a400-581de16f4e93	Par un reseau de capillaires sanguins intra-epitheliaux	f
0e8fde96-ddce-43c7-99ba-87cb7d660f6c	512c9497-6f70-4ecb-a4e1-bb2f16c3b5a7	Epithelium transitionnel urothelial	f
46d1e2f7-3c70-4505-a483-5d4b7b8ba62f	512c9497-6f70-4ecb-a4e1-bb2f16c3b5a7	Epithelium pavimenteux stratifie keratine	f
7aee7b3a-e8f7-4568-8344-c2b8d4a5306b	512c9497-6f70-4ecb-a4e1-bb2f16c3b5a7	Tissu conjonctif dense regulier	f
7cceb19d-26d2-40e8-acc3-b78259e85d52	512c9497-6f70-4ecb-a4e1-bb2f16c3b5a7	Epithelium cubique simple a bordure en brosse	t
210a43da-6e8e-4509-bb68-167cb33f0ce8	1b0f071b-2eef-470f-af2d-7f6ef4cd45a6	La jonction communicante (gap junction)	f
70d99c10-b22f-4daf-970f-0e7fd0da8ee7	1b0f071b-2eef-470f-af2d-7f6ef4cd45a6	Le complexe pericentriolaire	f
a563b417-dca5-40a8-98fe-4c8341fedecb	1b0f071b-2eef-470f-af2d-7f6ef4cd45a6	L'hemidesmosome basal	f
dca04163-17d1-4eb7-b3cc-6528a216a539	1b0f071b-2eef-470f-af2d-7f6ef4cd45a6	La jonction serree (zonula occludens)	t
3966278c-380b-4f9f-a929-38a2ea055ac2	de182ad2-e8a4-4dd1-8df4-ac634f34008a	La face laterale intercellulaire	f
65ba61cd-4147-42d2-a288-d03af64950b2	de182ad2-e8a4-4dd1-8df4-ac634f34008a	Le pole basal	t
ed672bde-a620-48c6-9921-5aaa8b865ea0	de182ad2-e8a4-4dd1-8df4-ac634f34008a	Le domaine ciliaire	f
fcd8b69f-a314-467e-b813-a0001e030d1e	de182ad2-e8a4-4dd1-8df4-ac634f34008a	Le pole apical	f
047d2af8-1366-4ff8-84a5-0db456162334	879bbd91-744a-432e-96f2-e0767fc7241d	Le fibroblaste	t
0a499c7d-7859-4c8b-8d3b-92554cb86c32	879bbd91-744a-432e-96f2-e0767fc7241d	L'enterocyte	f
2530eeeb-891b-4737-9d88-d0029de35f18	879bbd91-744a-432e-96f2-e0767fc7241d	Le chondrocyte	f
e9141bba-98c8-4e6a-9be9-2a4556fbffdc	879bbd91-744a-432e-96f2-e0767fc7241d	Le keratinocyte	f
63b47c5b-28bf-493d-bc4f-ec63125b6020	c9735774-152c-4d50-91ae-461be939a0ba	Elle est riche en substance fondamentale hydra-amorphe avec des fibres espacees	t
8b7f7a94-5641-4779-a4c9-0fcad08a00d1	c9735774-152c-4d50-91ae-461be939a0ba	Elle est solidement calcifiee et sans eau	f
bbd4835a-6310-4e81-9afd-d83ba08c6613	c9735774-152c-4d50-91ae-461be939a0ba	Elle est entierement constituee de fibres de collagene tassees sans substance fondamentale	f
cd8bdd67-3d1f-44f0-899f-d4da36d33f42	c9735774-152c-4d50-91ae-461be939a0ba	Elle est absente, les cellules etant jointives sans matrice	f
5d6e62ad-a787-4583-8717-835da0f76112	814f1e28-708e-4efa-914a-88fb6264458b	La keratine filamenteuse	f
7a64418a-63bf-4bd4-874e-6bc3e89b4140	814f1e28-708e-4efa-914a-88fb6264458b	Les molecules d'actine et de myosine	f
d4acde7b-d56f-446f-ad45-5cf98768aa68	814f1e28-708e-4efa-914a-88fb6264458b	Les glycosaminoglycanes (GAGs) et proteoglycanes	t
d55447b7-76e8-4558-9b8d-07e75dfc47de	814f1e28-708e-4efa-914a-88fb6264458b	L'hydroxyapatite de calcium	f
08f72b14-d3f8-4623-93c7-407a9b13791b	e57507fc-2f5b-4608-ad4f-dfa82176d36e	Il secrete l'acide gastrique chlorhydrique	f
258fad19-a669-43a8-a12a-ce635421770e	e57507fc-2f5b-4608-ad4f-dfa82176d36e	Il abrite des macrophages, plasmocytes et mastocytes pour la defense locale	t
4107d993-6ca3-416f-9fd9-25de89e0a4ab	e57507fc-2f5b-4608-ad4f-dfa82176d36e	Il genere les potentiels d'action moteurs	f
fe1d45eb-f06b-4e7e-8949-3dc7876561f4	e57507fc-2f5b-4608-ad4f-dfa82176d36e	Il synthetise exclusivement les hormones thyroïdiennes	f
0096b420-82a9-4a9f-aa0f-202469428de9	b077e396-3519-4def-8a09-1016e6eb8aa4	L'epinevre	f
0f4c357e-7a42-4bc5-9659-65ee4c81fe61	b077e396-3519-4def-8a09-1016e6eb8aa4	Le perichondre	f
afd69b20-4340-4997-9c33-7fb54034da76	b077e396-3519-4def-8a09-1016e6eb8aa4	Le perioste	f
d9e22edf-4366-4371-9d20-c4cfa4fa3823	b077e396-3519-4def-8a09-1016e6eb8aa4	Le chorion ou lamina propria	t
021dd367-58ae-49d9-b674-75832f656aa3	db9f1d17-e358-4a8c-b2e2-d16521a4fa1b	Les tonofilaments de keratine	f
0d7d8f65-2b12-466c-8f79-1e4717ca0cb4	db9f1d17-e358-4a8c-b2e2-d16521a4fa1b	Les myofibrilles d'actine	f
515e91ed-6ed9-49ca-8b2b-1625a6464f30	db9f1d17-e358-4a8c-b2e2-d16521a4fa1b	Les fibres elastiques formees d'elastine	t
68fda281-3341-4ade-b6fb-a2a47c14b2ce	db9f1d17-e358-4a8c-b2e2-d16521a4fa1b	Les trabecules osteoïdes	f
2743b50d-cf5c-47fe-8848-0762a3214def	1912e966-a572-43c3-8d26-fbba2a32edab	Il mute directement en ostéoblaste	f
35ff0856-b91b-4198-879a-f63079dc7475	1912e966-a572-43c3-8d26-fbba2a32edab	Il fusionne pour creer une fibre musculaire	f
9f7faed9-bb27-49cb-a11f-6ef9d1434ea5	1912e966-a572-43c3-8d26-fbba2a32edab	Il se transforme en fibrocyte quiescent	t
f3cd7fe2-d67e-49e7-b85c-ca5fed5b7f8b	1912e966-a572-43c3-8d26-fbba2a32edab	Il se detache pour devenir une hematie	f
34c28116-3063-4528-b283-4f867ea014bf	23d607d4-5ec9-44ad-accd-4c6d2b34a278	Circulaires concentriques autour des vaisseaux	f
545926f5-73f7-4d2f-a46d-b34598909551	23d607d4-5ec9-44ad-accd-4c6d2b34a278	Enchevêtrees en tout sens de façon desordonnee	f
6179c344-3ac4-4bb1-86f7-3980ed9a2d87	23d607d4-5ec9-44ad-accd-4c6d2b34a278	Paralleles et serrees le long de l'axe de traction (tissu dense regulier orienté)	t
e5d43e96-1929-48b2-a8d2-3f3b196956d2	23d607d4-5ec9-44ad-accd-4c6d2b34a278	Discontinuees sous forme de reseau spongieux	f
001e2b68-0d84-4576-8a37-63454652d87e	33a0c6e9-854f-4741-9d70-7ac2c9ee730c	Collagene de type IV	f
2195890a-057f-4f57-8706-a48db26aee0e	33a0c6e9-854f-4741-9d70-7ac2c9ee730c	Collagene de type IX	f
407f9f37-3505-4370-84b3-552f2929d098	33a0c6e9-854f-4741-9d70-7ac2c9ee730c	Collagene de type I	t
c0c4f83d-e451-4b32-8b7e-f5ce2ac60d01	33a0c6e9-854f-4741-9d70-7ac2c9ee730c	Collagene de type II	f
0342e182-78a5-41ff-8835-0fd30722f2a0	b5e5f9e0-4514-42af-b805-3c8ff198957a	A cause de la faible vascularisation propre et du métabolisme cellulaire reduit	t
5d01090f-e444-44d6-bf74-751db7220503	b5e5f9e0-4514-42af-b805-3c8ff198957a	En raison d'un excès incontrôlé de flux sanguin	f
95414fcb-9325-49f3-a920-906e5f0218cd	b5e5f9e0-4514-42af-b805-3c8ff198957a	Parce que les cellules sont totipotentes et prolifèrent trop vite	f
ce955954-97bc-4d52-aca7-8cb09f83f916	b5e5f9e0-4514-42af-b805-3c8ff198957a	A cause d'une destruction enzymatique automatique de l'actine	f
1fbe0d74-08af-4c2e-b5d9-ae57eb6acd77	92c6a3c2-af23-41fe-adc7-b06817012b9c	Les tenocytes	t
4988a654-0675-4100-b618-e013778eedf4	92c6a3c2-af23-41fe-adc7-b06817012b9c	Les pericytes	f
54b87bf6-112a-4bee-821c-aa3ffe102bc1	92c6a3c2-af23-41fe-adc7-b06817012b9c	Les cellules de Schwann	f
cac87b5d-a9ed-4725-970d-4f80d7ef815a	92c6a3c2-af23-41fe-adc7-b06817012b9c	Les chondrocytes	f
052037c8-a654-4c72-9063-fb2dfa1f7906	abd50429-6772-492d-a6db-ea87b6afaa9b	Tissu conjonctif dense non orienté (ou semi-orienté)	t
95cd3110-5791-41e0-a806-24f94e656cd7	abd50429-6772-492d-a6db-ea87b6afaa9b	Epithelium stratifie cylindrique	f
ca347b91-d28f-4be7-8a55-77221544a92b	abd50429-6772-492d-a6db-ea87b6afaa9b	Tissu cartilagineux elastique	f
fd5a57ec-f1bc-41da-9802-3468ce37889d	abd50429-6772-492d-a6db-ea87b6afaa9b	Tissu conjonctif dense régulier parfait	f
27d3f5b8-5910-48fb-a387-ff1b2416510f	3e209f85-302d-4443-98cc-56737ec3163c	L'epitendon (ou peritendon)	t
c0e91213-b474-4d27-ba8b-b8884690a09a	3e209f85-302d-4443-98cc-56737ec3163c	La capsule articulaire synoviale	f
d402df63-ca38-4a08-8927-a205b208c3cd	3e209f85-302d-4443-98cc-56737ec3163c	Le sarcolemme	f
fdca32cc-9ec3-41f3-8803-ad5fcbc0621c	3e209f85-302d-4443-98cc-56737ec3163c	L'endoste	f
002bd360-a1f9-4d47-a165-e0ee43212b23	19241858-cf62-42af-a266-ce22b8fdc601	Transparent incolore comme une vacuole	f
a00f3ff7-9764-4a17-900d-3886f0d761c1	19241858-cf62-42af-a266-ce22b8fdc601	Jaune fluorescent brillant	f
c74f6c2e-2d6e-4736-a8a3-849aa200c3a6	19241858-cf62-42af-a266-ce22b8fdc601	Rose intense / Eosinophile acidophile	t
f6374c4d-7acb-426b-8cf1-7b77a9134aba	19241858-cf62-42af-a266-ce22b8fdc601	Bleu foncé / Basophile intense	f
4d01be7f-9de6-477a-9ab5-f2b6d098323e	17c5ae82-467a-48a8-9d33-e9075a788067	Structure cylindrique multinucleee a striations transversales	f
5e585026-edfb-4f1c-884a-f078893f819e	17c5ae82-467a-48a8-9d33-e9075a788067	Cellule fusiforme sombre aux extremites effilees et noyau central	f
7bbaa3cb-f9a0-4115-8b31-9a5779b34949	17c5ae82-467a-48a8-9d33-e9075a788067	Cellule ramifiee aux prolongements dendritiques multiples	f
e87db983-af50-4ccc-9640-4bfb4a3d7a5d	17c5ae82-467a-48a8-9d33-e9075a788067	Aspect en 'bague a chaton' avec grand espace clair optiquement vide et noyau aplati en peripherie	t
03b9c4f2-d86c-49e4-bea4-2b65d5ac60a2	06cbc5e1-402e-4160-9df6-ebcb50e5e7ac	Le xylene (ou solvant de substitution) et les alcools	t
2bd3aff4-118d-4b45-80bf-b3fddb31cf77	06cbc5e1-402e-4160-9df6-ebcb50e5e7ac	L'hematoxyline ferrique	f
9c049268-5e2b-4211-b3bc-bfcc793266ac	06cbc5e1-402e-4160-9df6-ebcb50e5e7ac	L'azote liquide sous pression	f
be7b1b13-fcfb-46f2-b5df-df27b86d4988	06cbc5e1-402e-4160-9df6-ebcb50e5e7ac	L'eau distillee pure tamponnee	f
20db7d08-d433-44fd-b48a-9af5adb43880	c93cdf58-64a5-4df6-acd5-3eb56a39703d	Acides amines libres	f
676a2145-6d89-47ec-a704-ef91469b7e06	c93cdf58-64a5-4df6-acd5-3eb56a39703d	Cristaux d'urate	f
b0065f9d-a115-4655-9acb-795201535c6c	c93cdf58-64a5-4df6-acd5-3eb56a39703d	Triglycerides (triacylglycerols)	t
e2e8ff99-6756-454c-9fdc-bd25923609a9	c93cdf58-64a5-4df6-acd5-3eb56a39703d	Glycogene ramifie	f
061acdef-1453-4d74-9952-f1bf20c8cfb0	58689826-202f-4ff5-8085-e36c067148fb	Le glucagon	f
097fe215-257f-42a8-98d3-3d521c6dae22	58689826-202f-4ff5-8085-e36c067148fb	La leptine	t
9f6e9d9b-a501-4bb2-b60f-dc85f07d02fb	58689826-202f-4ff5-8085-e36c067148fb	La thyroxine	f
b8439645-88f5-4e07-b861-ca9dbfde514e	58689826-202f-4ff5-8085-e36c067148fb	L'insuline	f
30f83279-737d-43ce-84a8-26e2e0e8a816	83f26982-9762-4372-8e1a-9990826b9286	Oil Red O ou Rouge Soudan (Sudan III/IV)	t
7b5c8e7a-7651-464e-93f3-4a7467c9aafd	83f26982-9762-4372-8e1a-9990826b9286	Coloration de Gram	f
bed80997-8461-4741-bbda-193559748d5b	83f26982-9762-4372-8e1a-9990826b9286	Bleu de Coomassie	f
e25feb3c-eb8e-4940-aced-6b47210f1abf	83f26982-9762-4372-8e1a-9990826b9286	Coloration de Ziehl-Neelsen	f
6d19f18c-9265-40e4-86ee-a5aad673092a	2b2db09d-8b40-477a-9de4-eb26ffdfe375	Dote de sinusoides caverneux sans paroi propre	f
a2e7c6e0-fa6f-4419-a720-5666733dcb1e	2b2db09d-8b40-477a-9de4-eb26ffdfe375	Totalement avasculaire, la nutrition se faisant uniquement par l'air ambiant	f
bc7c0d01-ea40-4f59-b625-2cac5ccf83ff	2b2db09d-8b40-477a-9de4-eb26ffdfe375	Tres richement vascularise par un reseau dense de capillaires au contact de chaque adipocyte	t
bdd3adf6-ae9a-48fb-9d73-14b4b52aa3ae	2b2db09d-8b40-477a-9de4-eb26ffdfe375	Traverse par une unique veine centrale sans capillaires	f
59188df8-d9ba-40b9-9f56-b27e88c2d8de	83c2ac7d-a036-447a-8cc7-e7e4125ef346	Les adipocytes bruns sont depourvus de noyaux	f
7b778a35-28f2-4bb0-a41f-85f41dea894c	83c2ac7d-a036-447a-8cc7-e7e4125ef346	Les adipocytes bruns ne contiennent aucun lipide	f
88471b0b-af44-4126-bf41-c0b07e17827c	83c2ac7d-a036-447a-8cc7-e7e4125ef346	Les adipocytes bruns sont multiloculaires, riches en mitochondries et thermogeniques	t
8dc48998-9b2a-41d3-94cb-7bf33cf30aab	83c2ac7d-a036-447a-8cc7-e7e4125ef346	Le tissu brun est situe exclusivement dans le cartilage articulaire	f
0b311dc8-51b1-49ed-9443-9d4a95ef0a9b	c9f471d0-bd0d-4da5-9b7d-54d035db30ca	La couche basale (stratum basale ou germinativum)	t
1deffe02-aa1b-47e7-9014-28e48c520d69	c9f471d0-bd0d-4da5-9b7d-54d035db30ca	La couche cornee (stratum corneum)	f
a2fec0c8-858d-4c46-a9ac-e04feab36db3	c9f471d0-bd0d-4da5-9b7d-54d035db30ca	La couche granuleuse (stratum granulosum)	f
c36f6302-8f09-4658-811b-8500f80acb1c	c9f471d0-bd0d-4da5-9b7d-54d035db30ca	La couche papillaire profonde	f
2720fca2-32aa-478a-bd5f-ffca25073072	851bbad9-87a3-460b-acbd-6444e70d02f6	Cellules aplaties completement anucleees remplies de keratine	t
312a0f81-a838-4c31-92fd-7a510db885a1	851bbad9-87a3-460b-acbd-6444e70d02f6	Proliferation mitotique continue	f
64e2bcf5-b9d4-42d5-b115-f1a82ec2504d	851bbad9-87a3-460b-acbd-6444e70d02f6	Cellules cubiques vivantes a noyau volumineux	f
f74a9d74-a307-47f0-9718-4cca9bf9508a	851bbad9-87a3-460b-acbd-6444e70d02f6	Presence de nombreuses microvillosites absorbantes	f
45400053-acb7-41ff-9df0-6bd4774de0c3	afd2a73f-47ed-4a5b-99a0-f3bdebdf4c00	Les desmosomes (macula adherens)	t
751d68f4-88ba-45d1-90b4-7d620f82eac8	afd2a73f-47ed-4a5b-99a0-f3bdebdf4c00	Les invaginations mitochondriales	f
8b886992-6c94-41b5-8f2e-858a14a17a09	afd2a73f-47ed-4a5b-99a0-f3bdebdf4c00	Les synapses chimiques	f
a8473cd9-3e8d-441e-9bfa-df2b771ea431	afd2a73f-47ed-4a5b-99a0-f3bdebdf4c00	Les hemi-desmosomes uniquement	f
0e5fe720-63ac-4673-9baa-6b14468ecb80	561a430d-ecc0-4170-b294-7f68596ce25e	La cellule de Merkel	f
45cb624f-5dcf-4909-bb02-d1eae9a3ba0e	561a430d-ecc0-4170-b294-7f68596ce25e	Le mastocyte tissulaire	f
d3f70939-7d29-4236-91b8-911e6d605d10	561a430d-ecc0-4170-b294-7f68596ce25e	La cellule de Langerhans	f
d6ccce62-2bee-4200-b415-6f1a6c7ef1e5	561a430d-ecc0-4170-b294-7f68596ce25e	Le melanocyte	t
1225d374-66a5-4c24-b936-6a5cf9f21f8c	c7e59bcd-1ce7-4cb0-b1e0-ae2ec7c207ff	L'epithelium oesophagien est simple monostratifie	f
8415ec77-ded5-4e55-a67f-6a037e5015a6	c7e59bcd-1ce7-4cb0-b1e0-ae2ec7c207ff	L'oesophage est recouvert de plaques d'hydroxyapatite	f
e7455c3a-54e0-4798-b857-b91a4c23006f	c7e59bcd-1ce7-4cb0-b1e0-ae2ec7c207ff	L'oesophage ne possede pas de membrane basale	f
fc09b5d1-336d-4e7d-b601-ba52f72a1e1a	c7e59bcd-1ce7-4cb0-b1e0-ae2ec7c207ff	L'epithelium oesophagien est stratifie pavimenteux non keratinise (les cellules superficielles gardent leur noyau)	t
7a54c6aa-2481-472a-8c40-d5238e032720	36cfd1d5-66be-48a8-ac22-442bd73df0c9	Cellules presentatrices d'antigenes participant a l'immuno-surveillance cutanee	t
7d3019d6-4091-426f-9e72-da2e3ec95c55	36cfd1d5-66be-48a8-ac22-442bd73df0c9	Synthese des fibres de collagene tendineux	f
80d1e795-15e5-4a33-988a-c6414b4a2f3b	36cfd1d5-66be-48a8-ac22-442bd73df0c9	Production de sebum cutane	f
95ec89c1-3281-48fe-88a0-3521483f532f	36cfd1d5-66be-48a8-ac22-442bd73df0c9	Contraction pour la vasoconstriction	f
297bcc52-7500-48cf-972d-339a91f4e3b6	3ef9958c-2603-4860-af2b-a55014f7b43a	L'epiderme ne se renouvelle jamais apres la naissance	f
4971131a-cfb2-46e6-9352-1cb976fcd743	3ef9958c-2603-4860-af2b-a55014f7b43a	Plus de 10 annees	f
f05f2502-0c32-4468-a693-04a1797586f9	3ef9958c-2603-4860-af2b-a55014f7b43a	Environ 28 a 30 jours (4 semaines)	t
fa358911-9312-43a6-8854-24bd0af69f66	3ef9958c-2603-4860-af2b-a55014f7b43a	Moins de 2 heures	f
0961c4b6-f32a-467a-96f9-2b11b915246a	91b9524a-7ca0-4e5d-8fed-ee4560fc09f6	Unique et situe strictement au centre de la cellule	f
30830cfc-bec3-4089-a0f1-892021ec1d3b	91b9524a-7ca0-4e5d-8fed-ee4560fc09f6	Totalement absents comme dans les hematies	f
6cec0f48-7f0f-47be-9c3f-0278979f3d63	91b9524a-7ca0-4e5d-8fed-ee4560fc09f6	Multiples et rejetes en peripherie sous la membrane plasmique (sarcolemme)	t
c3dd1c1c-4bad-4cca-b757-f8597da27316	91b9524a-7ca0-4e5d-8fed-ee4560fc09f6	Localises a l'interieur des tubules T	f
1dbfeb78-cafb-4c6b-bf90-f991062772a7	8612c713-7a8f-49a9-bd43-6b25eb469d05	Le sarcolemme	f
25692194-456f-4999-bcb9-5636f1a6c398	8612c713-7a8f-49a9-bd43-6b25eb469d05	Le sarcomere	t
afa62c0a-301d-4271-8169-1c04eec5cd81	8612c713-7a8f-49a9-bd43-6b25eb469d05	Le fascicule musculaire	f
e5bf79c3-3b29-48a9-af77-a29ca0b5111e	8612c713-7a8f-49a9-bd43-6b25eb469d05	Le reticulum sarcoplasmique	f
4564b55f-d32b-45ec-8f28-59710187b4b9	8358eb36-8d40-4cd9-90a8-3f00253d956d	L'actine (filament fin) et la myosine (filament epais)	t
60a60949-b545-4c89-90f8-70804c4e4418	8358eb36-8d40-4cd9-90a8-3f00253d956d	L'albumine et la globuline	f
a338344e-aeba-41aa-b62d-b98ab8248a64	8358eb36-8d40-4cd9-90a8-3f00253d956d	L'elastine et le collagene	f
de27a758-ac4e-4ad7-b662-bc74bf0d34ec	8358eb36-8d40-4cd9-90a8-3f00253d956d	La keratine et la tubuline	f
026eadfb-c402-48d5-a3d6-675896d120e8	5687cbe1-144c-4a54-a8c5-bfbae1843340	Le reticulum sarcoplasmique (reticulum endoplasmique lisse specialise)	t
1a0656bb-3b55-4c64-8677-05dfd4d60e41	5687cbe1-144c-4a54-a8c5-bfbae1843340	Le peroxysome	f
23ded7c4-af96-40db-9582-14250bca2754	5687cbe1-144c-4a54-a8c5-bfbae1843340	L'appareil de Golgi perinucleaire	f
91e8d036-65fa-406b-a6bc-eb8f9204be45	5687cbe1-144c-4a54-a8c5-bfbae1843340	Le lysosome primaire	f
18e1a38a-42a5-4d37-9938-134c36bfd205	ded3dfec-9a16-41c9-a990-462266ae8354	L'endomysium	t
53ceb15f-93b7-4e0b-b9f0-77bbc8dde3f6	ded3dfec-9a16-41c9-a990-462266ae8354	Le perimysium	f
5484d8b2-d172-4174-b0fa-5d5f8eb01a13	ded3dfec-9a16-41c9-a990-462266ae8354	L'epinevre	f
79b1dfc7-b14d-45e6-9bee-5cd2d7b55a03	ded3dfec-9a16-41c9-a990-462266ae8354	L'epimysium	f
259f0565-fd52-4f27-8a21-3fcf95d220bc	da67d0f3-a177-4ecb-be5e-fe557709f74a	Le mastocyte	f
343a1332-6c05-44ef-88e5-462a9fc5a414	da67d0f3-a177-4ecb-be5e-fe557709f74a	La cellule satellite	t
412bb0e7-fb18-4dcf-b102-94f167a0bf6e	da67d0f3-a177-4ecb-be5e-fe557709f74a	Le melanocyte	f
c404d46d-1872-41ea-9ddc-e3c30c6ff284	da67d0f3-a177-4ecb-be5e-fe557709f74a	L'osteoclaste	f
028d200e-d98c-4bc9-b735-c44e4ad70969	07b99cc9-8c06-45ea-91ce-130df65e428f	La dopamine	f
23b88630-4389-4b86-b155-16955d1cbf66	07b99cc9-8c06-45ea-91ce-130df65e428f	Le GABA	f
bfb34405-e2fd-4219-a319-e9e964e253a2	07b99cc9-8c06-45ea-91ce-130df65e428f	L'acetylcholine	t
f17d6d32-466a-41fa-af54-9c6ad787b20d	07b99cc9-8c06-45ea-91ce-130df65e428f	La serotonine	f
34bd6301-c16e-48ab-bdb8-e3f836479974	417c9bd0-94d4-44e9-82d8-7d9fbf040902	Cylindre multinuclee geant a noyaux peripheriques	f
483c994c-0dfe-4b82-bab6-a6c74e4174e8	417c9bd0-94d4-44e9-82d8-7d9fbf040902	Sphere anucleee concave au centre	f
653188f2-615e-46d9-a426-e1ac415987ae	417c9bd0-94d4-44e9-82d8-7d9fbf040902	Cellule etoilee ramifiee a disques intercalaires	f
76787e59-07aa-4896-9f32-31e2b9a832d0	417c9bd0-94d4-44e9-82d8-7d9fbf040902	Cellule fusiforme effilee a noyau unique et central	t
36198797-ba05-4dc0-b959-a12ba52a7a80	cae74ad9-8783-4edb-93d6-b7922aa892ae	Il ne contient pas de proteines contractiles	f
77c18655-01bf-4fc4-9bf2-e0959076d7df	cae74ad9-8783-4edb-93d6-b7922aa892ae	Il est toujours enrobe de graisse fluide	f
bb04c859-e296-41de-a5b7-a9b5f3d17613	cae74ad9-8783-4edb-93d6-b7922aa892ae	Il ne presente pas de striation transversale car les myofilaments ne sont pas agences en sarcomeres reguliers	t
c948ecc2-41a8-4baa-a958-c349d1882a33	cae74ad9-8783-4edb-93d6-b7922aa892ae	Sa surface externe est depourvue de membrane plasmique	f
4466134f-2d4e-40d1-94ec-ca967bac3a3d	cb53b382-9847-4af4-9514-f60ead95413e	Les granulations de Nissl	f
5c667d71-db5e-44cd-84d7-1428eaaf221a	cb53b382-9847-4af4-9514-f60ead95413e	Les centrosomes mitotiques	f
7d0ae2ca-8df9-4090-af45-60429cf0b583	cb53b382-9847-4af4-9514-f60ead95413e	Les disques intercalaires scalariformes	f
a9a718c0-e26f-45d9-b093-f06f364dcce9	cb53b382-9847-4af4-9514-f60ead95413e	Les corps denses (dense bodies)	t
5c6f1ef9-88a6-48f8-8973-b7c9aaeecd80	72fa5995-3bf0-4a9b-9a66-814a164ed1fa	L'albumine serique	f
910e65cb-6a18-4bbe-8bbb-ba2e36e18569	72fa5995-3bf0-4a9b-9a66-814a164ed1fa	La troponine C	f
b66a12f2-2d4c-4db1-b990-d03fae92e361	72fa5995-3bf0-4a9b-9a66-814a164ed1fa	La ferritine	f
b871f0fa-5746-431b-86d1-8e82f2c4eb7d	72fa5995-3bf0-4a9b-9a66-814a164ed1fa	La calmoduline	t
034f1ac3-26c1-4e14-bed8-ab7e23c626e7	d3e79514-de12-479b-a26a-89d16c8a6849	Les synapses dopaminergiques	f
069ff71c-a616-49ac-98ca-7818599cf587	d3e79514-de12-479b-a26a-89d16c8a6849	Les hemidesmosomes cutanes	f
20405e9d-3d8f-477f-8edf-af39294de449	d3e79514-de12-479b-a26a-89d16c8a6849	Les jonctions communicantes (nexus ou gap junctions)	t
d73c13bb-2128-49be-8a0a-30ea905024c2	d3e79514-de12-479b-a26a-89d16c8a6849	Les jonctions d'ancrage cadherines seules	f
15f11941-7d81-4c47-b1a0-c68c42cb40fa	1de914a1-8861-441e-a63f-734b0cf23109	Le cortex moteur volontaire exclusivement	f
2ac271f3-a21c-4377-92e1-429f45f3751b	1de914a1-8861-441e-a63f-734b0cf23109	Le nerf optique	f
3aa02665-faa9-453e-a04a-841ea9ad803d	1de914a1-8861-441e-a63f-734b0cf23109	Le systeme nerveux autonome (vegetatif: sympathique et parasympathique)	t
83cf426a-79ae-4f6e-9bc8-156f88c61105	1de914a1-8861-441e-a63f-734b0cf23109	Le cervelet conscient	f
622a8411-ad08-4f67-8199-ad0a36958a9c	5ae146d8-badf-4905-86ff-d4c5244c0767	L'adventice superficielle	f
6b848507-59ce-4b5a-b947-1fe68277c97a	5ae146d8-badf-4905-86ff-d4c5244c0767	La tunique moyenne (media)	t
de2acb2f-54b0-4415-b76c-b308fa218ff6	5ae146d8-badf-4905-86ff-d4c5244c0767	L'endothelium	f
eed87a2c-fe59-4da6-b710-5ae34ac11bc1	5ae146d8-badf-4905-86ff-d4c5244c0767	L'intima	f
2d32aa2e-b239-4f23-8b78-899e7027c90d	bd711ca9-f997-4b54-b14c-7ec0f680a596	Le mastocyte	f
64dcd500-ff2d-467c-a47e-51b057e4c516	bd711ca9-f997-4b54-b14c-7ec0f680a596	L'osteoclaste	f
f400a78a-716d-4acf-ba73-b27dd67dc264	bd711ca9-f997-4b54-b14c-7ec0f680a596	Le chondrocyte	t
ff93e50f-d90b-4c3c-8237-f178873c49b4	bd711ca9-f997-4b54-b14c-7ec0f680a596	Le rhabdomyocyte	f
582f9715-b0aa-4be5-941d-cf55ddf34b23	a0dbfd7c-d291-4acf-ae8f-3285b6c1ed1a	Le canal de Havers	f
6698cfc4-2810-4655-b335-2e3885754893	a0dbfd7c-d291-4acf-ae8f-3285b6c1ed1a	La vacuole pinocytaire	f
a3922eae-5a3d-417a-9001-7113a4f1bc1f	a0dbfd7c-d291-4acf-ae8f-3285b6c1ed1a	Le follicule glandulaire	f
b9dab166-a22e-4e73-b3f0-fd8f009d8e8a	a0dbfd7c-d291-4acf-ae8f-3285b6c1ed1a	Le chondroplaste	t
2e3af534-549e-4e37-bcbd-38f09d35e55a	57125316-f9a3-4858-aca3-5c1f0e8fdee8	Le collagene de type I	f
87daa055-9e00-40bc-aef7-71983a087699	57125316-f9a3-4858-aca3-5c1f0e8fdee8	Le collagene de type IV	f
c71ed9e0-e50f-4363-919d-a458040bd334	57125316-f9a3-4858-aca3-5c1f0e8fdee8	Le collagene de type VII	f
f2504462-75af-404b-bed2-564265b350df	57125316-f9a3-4858-aca3-5c1f0e8fdee8	Le collagene de type II	t
0669a958-6560-4b3b-b148-f9c4dfd812fa	451cc023-6446-47a4-bab4-12ff0ae04901	Par des vaisseaux chyliferes lymphatiques	f
4534eb03-e986-42dc-850d-2bd35851a4e5	451cc023-6446-47a4-bab4-12ff0ae04901	Par des arteres coronaires penetrantes	f
5f8208ef-4a6a-45fb-8169-3ddbd9265ab4	451cc023-6446-47a4-bab4-12ff0ae04901	Par imbibition et diffusion a partir du liquide synovial intra-articulaire	t
f80638a6-6d19-4f98-b15d-de946dd7beff	451cc023-6446-47a4-bab4-12ff0ae04901	Par phagocytose des sels mineraux osseux	f
76269d1b-bbb2-4af4-ae2c-49cf2c0aaf33	89154457-21cf-4674-a16a-829b7077a472	Le perichondre	t
86e0df1a-ad61-45e6-b2d7-32fd10a7ca17	89154457-21cf-4674-a16a-829b7077a472	Le perioste	f
8e9e349c-4f4d-4d72-ac1e-5aa1ec89401e	89154457-21cf-4674-a16a-829b7077a472	La dure-mere	f
c23a6b3b-e586-4536-98ed-64cc658e39a2	89154457-21cf-4674-a16a-829b7077a472	Le perimysium	f
2f49e81c-d054-41a5-8610-ba97c7085441	ecbf62f3-0e7e-4315-955a-8f2984aacf80	Tres faible a quasi nulle en raison de son avascularite	t
8eac5dc1-e86d-4db1-8dd4-ea7541392096	ecbf62f3-0e7e-4315-955a-8f2984aacf80	Similaire a celle de la moelle osseuse	f
ed05ad48-1527-4067-a0e0-da3aea8cf457	ecbf62f3-0e7e-4315-955a-8f2984aacf80	Permanente et sans cicatrice fibreuse	f
f59c9e12-6244-453b-a0d8-23e313780f01	ecbf62f3-0e7e-4315-955a-8f2984aacf80	Hyper-rapide avec reconstitution complete en 48 heures	f
12647c3f-d2c9-4964-9eeb-ddd8abb10542	e3cb3313-5415-47d5-bac0-5b2a5570eb0b	Le glycogene cellulaire	f
67f9cc27-43e5-4ac4-9ff1-f66d083464c4	e3cb3313-5415-47d5-bac0-5b2a5570eb0b	La cellulose vegetale	f
7a7fcf8d-37da-4e94-845a-6b7a3a8f4947	e3cb3313-5415-47d5-bac0-5b2a5570eb0b	Le chondroïtine sulfate (associe au keratane sulfate)	t
d8d7d41d-c4ab-4ec6-b6a7-d85b0ad40bf3	e3cb3313-5415-47d5-bac0-5b2a5570eb0b	L'amidon	f
532c21b8-a91e-4b69-9e52-714754ee718d	d4893cf6-1fd9-437a-b990-f5d681a0f3a7	L'osteon (ou systeme de Havers)	t
823d4ed3-56ef-4db6-a6f6-6e06e4f3532d	d4893cf6-1fd9-437a-b990-f5d681a0f3a7	Le follicule primaire	f
e74edb51-2db1-4060-a6c2-79f448c971a5	d4893cf6-1fd9-437a-b990-f5d681a0f3a7	Le nephron renal	f
f8f72dc4-df8f-48b8-a026-39050d6f32cb	d4893cf6-1fd9-437a-b990-f5d681a0f3a7	Le sarcomere	f
67fc05d1-35f0-4baa-81da-8299d8d44ede	9b17d109-899b-4be5-9ec8-f1ac67735349	L'osteoblaste synthese	f
98b5728e-9b78-4a38-a335-05e35fbc1e56	9b17d109-899b-4be5-9ec8-f1ac67735349	L'osteoclaste (cellule geante multinucleee)	t
9d49956b-e2ca-4ff1-9a90-b375b0008600	9b17d109-899b-4be5-9ec8-f1ac67735349	Le fibroblaste capsulaire	f
ece04978-d51d-4b8b-9058-0b41b858164a	9b17d109-899b-4be5-9ec8-f1ac67735349	L'osteocyte quiescent	f
0145edc1-64d0-411e-8a90-b52589f8a4ec	84507cfc-8ed7-4ae7-a964-f47c30b49454	L'hydroxyapatite de calcium [Ca10(PO4)6(OH)2]	t
226f156d-c641-41ef-a412-46804fee4d95	84507cfc-8ed7-4ae7-a964-f47c30b49454	Le sulfate de magnesium	f
493a660d-9c16-40b8-b00b-a6f08b6ff7d9	84507cfc-8ed7-4ae7-a964-f47c30b49454	Le chlorure de sodium pur	f
8970bb4d-6d3b-4234-8ebe-245d1911939a	84507cfc-8ed7-4ae7-a964-f47c30b49454	Le bicarbonate de potassium	f
2d262119-6855-4bb1-adc3-b4132f906749	183cfa85-a687-43d8-973c-671f6d277a5e	Par emission de bulles lipidiques	f
5391dc27-12bf-4bcb-b97a-415a6bde06c3	183cfa85-a687-43d8-973c-671f6d277a5e	Ils ne communiquent absolument jamais	f
b256802c-aacd-4368-bc96-f163c6420881	183cfa85-a687-43d8-973c-671f6d277a5e	Par de fins canalicules osseux reliant leurs prolongements cytoplasmiques	t
b54d4ab9-acfc-4005-a160-91b51eef2d45	183cfa85-a687-43d8-973c-671f6d277a5e	Par les tubules en T transversaux	f
27c36838-4a43-4f32-a198-7475e9d757d1	62eb11b0-5751-43f9-93aa-1ef2b20b7307	Le canal de Volkmann	f
325887d7-d375-4485-9f60-058265416dd7	62eb11b0-5751-43f9-93aa-1ef2b20b7307	Le canal rachidien	f
67514baa-b6a4-4984-8862-aac87b18f783	62eb11b0-5751-43f9-93aa-1ef2b20b7307	Le canal de Havers	t
d88ce65c-070b-4fde-a970-806e06b09e62	62eb11b0-5751-43f9-93aa-1ef2b20b7307	Le canal cochleaire	f
3f6caf64-362b-4df1-8c39-d2a4932c3166	918bcb68-724f-4c1b-9c2c-5e0082719a51	Le perioste	t
c49a193f-6079-475d-9786-11b4c426c2fc	918bcb68-724f-4c1b-9c2c-5e0082719a51	L'epimysium	f
d906eee0-380e-4da1-99c2-dc93c84c73f4	918bcb68-724f-4c1b-9c2c-5e0082719a51	Le perichondre	f
efbd04ee-80e8-434a-b2a2-1a7272822b17	918bcb68-724f-4c1b-9c2c-5e0082719a51	L'endoste	f
1c90c3a1-735c-4c7d-a9db-4df5188956d0	1bd5e79c-325e-49f7-b980-5d8c0d83c7ed	L'osteocyte	f
3ca64ad5-16ca-4024-996c-a64b9b2dc7f9	1bd5e79c-325e-49f7-b980-5d8c0d83c7ed	L'osteoblaste	t
65dfd60b-21d8-4b06-9fc1-31a3e2db7f25	1bd5e79c-325e-49f7-b980-5d8c0d83c7ed	Le chondroblaste	f
f91620e8-787f-4928-adf6-a835f6d618a9	1bd5e79c-325e-49f7-b980-5d8c0d83c7ed	L'osteoclaste	f
\.


--
-- Data for Name: Organes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Organes" ("Id", "Nom", "UrlImage") FROM stdin;
33333333-3333-3333-3333-333333333333	Épiderme	
54316efe-0dcd-4456-8a83-921f590cfa6d	Rein (Tubules & Nephrons)	
a7287227-419b-4df7-8043-4fd3b468af8b	Intestin grele	
532a6b02-24c1-445d-99aa-f4b18780f0fe	Peau (Epiderme & Derme)	
619cb273-9f13-42d8-8b49-04f943610ed8	Oesophage	
7c21d61a-4964-46ca-878c-165a25423c96	Tendon & Ligament	
d44b14e4-43dd-4c76-b95a-dbc9acf0a7a2	Hypoderme (Sous-cutane)	
fd119514-f4dc-4316-bb12-c4c3cf69a7c6	Muscle squelettique (Biceps)	
f5fd0abb-b036-4ac6-befc-5f1fe7bd2394	Diaphragme & Langue	
304fa989-e65d-4d12-9cc2-b6e74388bdbe	Paroi digestive (Musculeuse)	
5263d2bb-967d-483a-9476-a610538cd327	Arteres & Vaisseaux sanguins	
525387ae-db28-4e7d-975d-97c20b2553c2	Trachee & Anneaux bronchiques	
324e254d-28f1-4e0f-841b-00d06798562b	Cartilage articulaire	
fc7abfa6-af6a-4875-8966-538f7e02f6a7	Os long (Femur / Diaphyse)	
\.


--
-- Data for Name: Questions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Questions" ("Id", "TissuId", "Texte") FROM stdin;
535cb570-f160-43dd-996b-592037922144	a7e611c5-4a0c-4c17-84f2-b41027039bea	Quel est le trait distinctif morphologique majeur d'un epithelium simple ?
3bfb19f4-df87-473e-8cf2-e90bae54d7df	a7e611c5-4a0c-4c17-84f2-b41027039bea	Au niveau des enterocytes de l'intestin grele, quelle specialisation apicale optimise l'absorption ?
7f4286b6-d63f-414d-8c0b-23b97e20ca0e	a7e611c5-4a0c-4c17-84f2-b41027039bea	Quel type cellulaire glandulaire intercale observe-t-on frequemment dans l'epithelium prismatique simple intestinal ?
d4c71fd5-b991-4b63-a400-581de16f4e93	a7e611c5-4a0c-4c17-84f2-b41027039bea	Comment les epitheliums simples assurent-ils leur nutrition en l'absence de vascularisation propre ?
512c9497-6f70-4ecb-a4e1-bb2f16c3b5a7	a7e611c5-4a0c-4c17-84f2-b41027039bea	Dans les tubules contournes proximaux du rein, l'epithelium est de quel type ?
1b0f071b-2eef-470f-af2d-7f6ef4cd45a6	a7e611c5-4a0c-4c17-84f2-b41027039bea	Quelle structure jonctionnelle assure l'etancheite et empeche le passage paracellulaire dans l'epithelium simple ?
de182ad2-e8a4-4dd1-8df4-ac634f34008a	a7e611c5-4a0c-4c17-84f2-b41027039bea	Quel pole de la cellule epitheliale est en contact direct avec la lame basale ?
879bbd91-744a-432e-96f2-e0767fc7241d	a908b6ef-917c-42fe-80ed-d45299cd2e42	Quelle cellule est la principale responsable de la synthese de la matrice extracellulaire dans le tissu conjonctif lache ?
c9735774-152c-4d50-91ae-461be939a0ba	a908b6ef-917c-42fe-80ed-d45299cd2e42	Quelle est la principale caracteristique de la matrice extracellulaire du tissu conjonctif lache ?
814f1e28-708e-4efa-914a-88fb6264458b	a908b6ef-917c-42fe-80ed-d45299cd2e42	Quel composant moleculaire confere a la substance fondamentale sa capacite elevee de retention d'eau ?
e57507fc-2f5b-4608-ad4f-dfa82176d36e	a908b6ef-917c-42fe-80ed-d45299cd2e42	Quel role immunitaire joue le chorion constitue de tissu conjonctif lache ?
b077e396-3519-4def-8a09-1016e6eb8aa4	a908b6ef-917c-42fe-80ed-d45299cd2e42	Comment appelle-t-on le tissu conjonctif lache soutenant les epitheliums des muqueuses digestives ?
db9f1d17-e358-4a8c-b2e2-d16521a4fa1b	a908b6ef-917c-42fe-80ed-d45299cd2e42	Quelles fibres extracellulaires conferent l'elasticite et la flexibilite au tissu conjonctif lache ?
1912e966-a572-43c3-8d26-fbba2a32edab	a908b6ef-917c-42fe-80ed-d45299cd2e42	Quelle est l'evolution du fibroblaste lorsqu'il devient moins actif metaboliquement ?
23d607d4-5ec9-44ad-accd-4c6d2b34a278	dae13273-a91b-490a-8a29-6154a0d2d9f0	Dans un tendon, comment sont orientees les fibres de collagene de type I ?
33a0c6e9-854f-4741-9d70-7ac2c9ee730c	dae13273-a91b-490a-8a29-6154a0d2d9f0	Quel type de collagene predomine largement dans le tissu conjonctif dense des tendons et ligaments ?
b5e5f9e0-4514-42af-b805-3c8ff198957a	dae13273-a91b-490a-8a29-6154a0d2d9f0	Pourquoi les lesions tendineuses cicatrisent-elles generalement tres lentement ?
92c6a3c2-af23-41fe-adc7-b06817012b9c	dae13273-a91b-490a-8a29-6154a0d2d9f0	Quelle est la denomination des fibroblastes specifiques loges et allonges entre les faisceaux d'un tendon ?
abd50429-6772-492d-a6db-ea87b6afaa9b	dae13273-a91b-490a-8a29-6154a0d2d9f0	Le derme reticulaire profond de la peau est un exemple de :
3e209f85-302d-4443-98cc-56737ec3163c	dae13273-a91b-490a-8a29-6154a0d2d9f0	Par quel type de gaine de tissu conjonctif lache vascularise le tendon est-il entoure ?
19241858-cf62-42af-a266-ce22b8fdc601	dae13273-a91b-490a-8a29-6154a0d2d9f0	Sous coloration a l'Hematoxyline-Eosine, quelle est la teinte caracteristique des faisceaux de collagene ?
17c5ae82-467a-48a8-9d33-e9075a788067	e1267403-5409-4d98-8735-9e56a84ae8cd	Quelle est l'apparence morphologique classique de l'adipocyte blanc sur une coupe histologique standard apres dissolution des graisses ?
06cbc5e1-402e-4160-9df6-ebcb50e5e7ac	e1267403-5409-4d98-8735-9e56a84ae8cd	Quel solvant organique utilise lors de la preparation histologique paraffine dissout les lipides intracellulaires ?
c93cdf58-64a5-4df6-acd5-3eb56a39703d	e1267403-5409-4d98-8735-9e56a84ae8cd	Sous quelle forme moleculaire les lipides sont-ils principalement stockes dans l'adipocyte blanc ?
58689826-202f-4ff5-8085-e36c067148fb	e1267403-5409-4d98-8735-9e56a84ae8cd	Quelle hormone endocrine majeure est produite par le tissu adipeux pour reguler la satiete ?
83f26982-9762-4372-8e1a-9990826b9286	e1267403-5409-4d98-8735-9e56a84ae8cd	Quelle coloration histochimique specifique sur coupes en congelation permet de reveler les lipides neutres ?
2b2db09d-8b40-477a-9de4-eb26ffdfe375	e1267403-5409-4d98-8735-9e56a84ae8cd	Comment est vascularise le tissu adipeux blanc ?
83c2ac7d-a036-447a-8cc7-e7e4125ef346	e1267403-5409-4d98-8735-9e56a84ae8cd	En quoi le tissu adipeux brun se distingue-t-il histologiquement du tissu adipeux blanc ?
c9f471d0-bd0d-4da5-9b7d-54d035db30ca	22222222-2222-2222-2222-222222222222	Quelle couche de l'epithelium stratifie pavimenteux contient les cellules souches en mitose active ?
851bbad9-87a3-460b-acbd-6444e70d02f6	22222222-2222-2222-2222-222222222222	Dans l'epiderme (keratinise), quelle est la caracteristique cellulaire distinctive de la couche cornee ?
afd2a73f-47ed-4a5b-99a0-f3bdebdf4c00	22222222-2222-2222-2222-222222222222	Quelle jonction intercellulaire abondante donne a la couche epineuse (stratum spinosum) son aspect epineux ?
561a430d-ecc0-4170-b294-7f68596ce25e	22222222-2222-2222-2222-222222222222	Quelle cellule pigmentaire localisee dans la couche basale produit la melanine protegeant contre les UV ?
c7e59bcd-1ce7-4cb0-b1e0-ae2ec7c207ff	22222222-2222-2222-2222-222222222222	Quelle est la principale difference histologique entre l'epithelium de l'oesophage et celui de l'epiderme cutane ?
36cfd1d5-66be-48a8-ac22-442bd73df0c9	22222222-2222-2222-2222-222222222222	Quel role jouent les cellules de Langerhans presentes dans l'epithelium stratifie pavimenteux ?
3ef9958c-2603-4860-af2b-a55014f7b43a	22222222-2222-2222-2222-222222222222	Quel est le temps moyen de renouvellement complet de l'epiderme humain par migration des keratinocytes ?
91b9524a-7ca0-4e5d-8fed-ee4560fc09f6	55aaed8c-7b6c-4eae-aeb0-bdd241e142a9	Quelle est la localisation des noyaux dans une fibre musculaire striee squelettique ?
8612c713-7a8f-49a9-bd43-6b25eb469d05	55aaed8c-7b6c-4eae-aeb0-bdd241e142a9	Quelle est l'unite contractile elementaire du muscle strie delimitee par deux stries Z ?
8358eb36-8d40-4cd9-90a8-3f00253d956d	55aaed8c-7b6c-4eae-aeb0-bdd241e142a9	Quelles sont les deux principales proteines myofilamentaires impliquees dans le glissement et le raccourcissement sarcomere ?
5687cbe1-144c-4a54-a8c5-bfbae1843340	55aaed8c-7b6c-4eae-aeb0-bdd241e142a9	Quel organite specifique stocke et libere massivement les ions calcium necessaires a la contraction musculaire ?
ded3dfec-9a16-41c9-a990-462266ae8354	55aaed8c-7b6c-4eae-aeb0-bdd241e142a9	Comment se nomme la gaine de tissu conjonctif qui entoure chaque fibre musculaire individuelle ?
da67d0f3-a177-4ecb-be5e-fe557709f74a	55aaed8c-7b6c-4eae-aeb0-bdd241e142a9	Quelle cellule quiescente juxtaposee a la fibre musculaire squelettique permet sa regeneration en cas de lesion ?
07b99cc9-8c06-45ea-91ce-130df65e428f	55aaed8c-7b6c-4eae-aeb0-bdd241e142a9	A quel neurotransmetteur la jonction neuromusculaire (plaque motrice) repond-elle pour declencher la depolarisation ?
417c9bd0-94d4-44e9-82d8-7d9fbf040902	f51d3b45-c5f8-488f-888c-4c096ff5c3cd	Quelle est la morphologie caracteristique d'une cellule musculaire lisse (leiomyocyte) ?
cae74ad9-8783-4edb-93d6-b7922aa892ae	f51d3b45-c5f8-488f-888c-4c096ff5c3cd	Pourquoi le muscle lisse est-il qualifie de 'lisse' au microscope optique ?
cb53b382-9847-4af4-9514-f60ead95413e	f51d3b45-c5f8-488f-888c-4c096ff5c3cd	Quelle structure d'ancrage cytoplasmique et membranaire remplit dans le muscle lisse le role des stries Z du muscle strie ?
72fa5995-3bf0-4a9b-9a66-814a164ed1fa	f51d3b45-c5f8-488f-888c-4c096ff5c3cd	Quelle proteine regulatrice intracellulaire lie le calcium pour activer la kinase des chaines legeres de myosine (MLCK) ?
d3e79514-de12-479b-a26a-89d16c8a6849	f51d3b45-c5f8-488f-888c-4c096ff5c3cd	Quel type de jonction intercellulaire couple electriquement les cellules musculaires lisses pour synchroniser la contraction peristaltique ?
1de914a1-8861-441e-a63f-734b0cf23109	f51d3b45-c5f8-488f-888c-4c096ff5c3cd	Par quel systeme nerveux l'activite du muscle lisse est-elle principalement controlee ?
5ae146d8-badf-4905-86ff-d4c5244c0767	f51d3b45-c5f8-488f-888c-4c096ff5c3cd	Dans la paroi des arteres de moyen et gros calibre, dans quelle tunique histologique trouve-t-on le muscle lisse ?
bd711ca9-f997-4b54-b14c-7ec0f680a596	2b6c522b-307c-4ee1-ac33-38072e3cfbe7	Quel est le type cellulaire residant mature responsable de l'entretien de la matrice cartilagineuse ?
a0dbfd7c-d291-4acf-ae8f-3285b6c1ed1a	2b6c522b-307c-4ee1-ac33-38072e3cfbe7	Comment s'appelle la petite logette de la matrice extracellulaire dans laquelle est isole chaque chondrocyte ?
57125316-f9a3-4858-aca3-5c1f0e8fdee8	2b6c522b-307c-4ee1-ac33-38072e3cfbe7	Quel type de collagene caracterise specifiquement la matrice du cartilage hyalin ?
451cc023-6446-47a4-bab4-12ff0ae04901	2b6c522b-307c-4ee1-ac33-38072e3cfbe7	Comment le cartilage articulaire hyalin assure-t-il sa nutrition en l'absence de perichondre ?
89154457-21cf-4674-a16a-829b7077a472	2b6c522b-307c-4ee1-ac33-38072e3cfbe7	Comment appelle-t-on l'enveloppe conjonctive vascularisee qui borde le cartilage non articulaire (comme dans la trachee) ?
ecbf62f3-0e7e-4315-955a-8f2984aacf80	2b6c522b-307c-4ee1-ac33-38072e3cfbe7	Quelle capacite de regeneration autonome possede le tissu cartilagineux adulte chez l'homme ?
e3cb3313-5415-47d5-bac0-5b2a5570eb0b	2b6c522b-307c-4ee1-ac33-38072e3cfbe7	Quel polysaccharide sulfate hautement hydrophile constitue le proteoglycane majeur (aggrecane) du cartilage ?
d4893cf6-1fd9-437a-b990-f5d681a0f3a7	732c7894-b45f-482b-af2b-5e8c2b0f4037	Quelle est l'unite structurale et fonctionnelle de base de l'os compact (diaphysaire) ?
9b17d109-899b-4be5-9ec8-f1ac67735349	732c7894-b45f-482b-af2b-5e8c2b0f4037	Quelle est la cellule responsable de la resorption osseuse et du remodelage de la matrice ?
84507cfc-8ed7-4ae7-a964-f47c30b49454	732c7894-b45f-482b-af2b-5e8c2b0f4037	Quel sel mineral compose en majorite la phase minerale inorganique de la matrice osseuse ?
183cfa85-a687-43d8-973c-671f6d277a5e	732c7894-b45f-482b-af2b-5e8c2b0f4037	Comment communiquent entre eux les osteocytes enfermes dans leurs osteoplastes au sein des lamelles osseuses ?
62eb11b0-5751-43f9-93aa-1ef2b20b7307	732c7894-b45f-482b-af2b-5e8c2b0f4037	Quel canal longitudinal au centre de chaque osteon abrite des capillaires sanguins et des fibres nerveuses ?
918bcb68-724f-4c1b-9c2c-5e0082719a51	732c7894-b45f-482b-af2b-5e8c2b0f4037	Quelle membrane conjonctive externe richement vascularisee et inervee recouvre la surface externe de l'os (hors cartilage) ?
1bd5e79c-325e-49f7-b980-5d8c0d83c7ed	732c7894-b45f-482b-af2b-5e8c2b0f4037	Quelle cellule jeune osseuse synthetise activement la fraction organique de la matrice (substance osteoïde) ?
\.


--
-- Data for Name: ResultatsQCM; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."ResultatsQCM" ("Id", "UtilisateurId", "ScanId", "Note", "DateTest") FROM stdin;
9293036d-47fb-45b6-9337-b61531fe329d	11111111-1111-1111-1111-111111111111	2326357f-41f6-4dae-b4ed-0012ec162313	3	2026-08-27 12:02:38.406921+00
\.


--
-- Data for Name: Scans; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Scans" ("Id", "UtilisateurId", "TissuId", "UrlImage", "ScoreConfiance", "DateScan") FROM stdin;
2326357f-41f6-4dae-b4ed-0012ec162313	11111111-1111-1111-1111-111111111111	55aaed8c-7b6c-4eae-aeb0-bdd241e142a9	http://localhost:9000/histoclass-images/366dd7b2-32d3-48c7-8eeb-b04cf5b410d0.png	0.9998	2026-08-27 11:49:18.204974+00
6e799889-cadf-46d0-a99a-a7763a5c30fe	f80d5fe6-889f-4c27-b3bc-c0def887e69e	f51d3b45-c5f8-488f-888c-4c096ff5c3cd	http://192.168.3.133:9000/histoclass-images/d88049df-4e11-4550-b948-5ff3b62a81be.jpg	0.9918	2026-09-02 21:54:55.644392+00
0b43beaf-c760-4839-b4d2-b55ee6d2e6ef	f80d5fe6-889f-4c27-b3bc-c0def887e69e	a908b6ef-917c-42fe-80ed-d45299cd2e42	http://192.168.3.133:9000/histoclass-images/a1ba9af3-fe81-4063-8b2d-7e2dba7a9aab.jpg	0.7469	2026-09-02 23:21:16.051571+00
\.


--
-- Data for Name: TissuOrganes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."TissuOrganes" ("TissuId", "OrganeId") FROM stdin;
a7e611c5-4a0c-4c17-84f2-b41027039bea	54316efe-0dcd-4456-8a83-921f590cfa6d
a7e611c5-4a0c-4c17-84f2-b41027039bea	a7287227-419b-4df7-8043-4fd3b468af8b
a908b6ef-917c-42fe-80ed-d45299cd2e42	304fa989-e65d-4d12-9cc2-b6e74388bdbe
a908b6ef-917c-42fe-80ed-d45299cd2e42	532a6b02-24c1-445d-99aa-f4b18780f0fe
dae13273-a91b-490a-8a29-6154a0d2d9f0	532a6b02-24c1-445d-99aa-f4b18780f0fe
dae13273-a91b-490a-8a29-6154a0d2d9f0	7c21d61a-4964-46ca-878c-165a25423c96
e1267403-5409-4d98-8735-9e56a84ae8cd	532a6b02-24c1-445d-99aa-f4b18780f0fe
e1267403-5409-4d98-8735-9e56a84ae8cd	d44b14e4-43dd-4c76-b95a-dbc9acf0a7a2
22222222-2222-2222-2222-222222222222	532a6b02-24c1-445d-99aa-f4b18780f0fe
22222222-2222-2222-2222-222222222222	619cb273-9f13-42d8-8b49-04f943610ed8
55aaed8c-7b6c-4eae-aeb0-bdd241e142a9	f5fd0abb-b036-4ac6-befc-5f1fe7bd2394
55aaed8c-7b6c-4eae-aeb0-bdd241e142a9	fd119514-f4dc-4316-bb12-c4c3cf69a7c6
f51d3b45-c5f8-488f-888c-4c096ff5c3cd	304fa989-e65d-4d12-9cc2-b6e74388bdbe
f51d3b45-c5f8-488f-888c-4c096ff5c3cd	5263d2bb-967d-483a-9476-a610538cd327
2b6c522b-307c-4ee1-ac33-38072e3cfbe7	324e254d-28f1-4e0f-841b-00d06798562b
2b6c522b-307c-4ee1-ac33-38072e3cfbe7	525387ae-db28-4e7d-975d-97c20b2553c2
732c7894-b45f-482b-af2b-5e8c2b0f4037	fc7abfa6-af6a-4875-8966-538f7e02f6a7
\.


--
-- Data for Name: Tissus; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Tissus" ("Id", "Nom", "CodeLabelIa", "Description", "Fonctions") FROM stdin;
a7e611c5-4a0c-4c17-84f2-b41027039bea	Tissu Epithelial Simple	classe_00	Epithelium unistratifie forme d'une couche unique de cellules (cubiques ou prismatiques) reposant sur une lame basale bien individualisee.	Absorption selective des nutriments, secretion enzymatique ou muqueuse, et filtration liquidienne.
a908b6ef-917c-42fe-80ed-d45299cd2e42	Tissu Conjonctif Lache (Stroma)	classe_01	Tissu de soutien ubiquitaire comportant une proportion equilibree de cellules, de fibres de collagene minces et de substance fondamentale riche en eau.	Support mecanique souple, nutrition des epitheliums, vehicule des cellules immunitaires et cicatrisation.
dae13273-a91b-490a-8a29-6154a0d2d9f0	Tissu Conjonctif Dense	classe_02	Tissu caracterise par une abondance massive de volumineux faisceaux de collagene compacts avec peu de cellules et peu de substance fondamentale.	Resistance maximale aux fortes contraintes mecaniques et forces de traction multidirectionnelles ou axiales.
e1267403-5409-4d98-8735-9e56a84ae8cd	Tissu Adipeux (Graisse Blanche)	classe_03	Tissu conjonctif specialise constitue de volumineuses cellules arrondies remplies d'une vacuole lipidique unique refoulant le noyau aplati en peripherie.	Reserve energetique majeure sous forme de triglycerides, isolation thermique corporelle et protection mecanique contre les chocs.
22222222-2222-2222-2222-222222222222	Epithelium Stratifie Pavimenteux	classe_04	Epithelium compose de nombreuses assises cellulaires superposees dont les cellules des couches superficielles sont aplaties en squames.	Protection mecanique majeure contre l'usure, barriere chimique et microbiologique contre les infections et agressions exogenes.
55aaed8c-7b6c-4eae-aeb0-bdd241e142a9	Tissu Musculaire Squelettique (Strie)	classe_05	Tissu contractile compose de volumineux syncytiums cylindriques (rhabdomyocytes) multinuclees a noyaux peripheriques et a striation transversale visible.	Contractions puissantes, rapides et volontaires assurant la motricite du squelette, le maintien postural et la production de chaleur.
f51d3b45-c5f8-488f-888c-4c096ff5c3cd	Tissu Musculaire Lisse	classe_06	Cellules fusiformes mononuclees (leiomyocytes) a extremites effilees et a noyau central ovalaire, depourvues de striation transversale evidente.	Contractions involontaires, lentes et continues assurant le peristaltisme viscéral, le tonus vasculaire et la motilite des organes creux.
2b6c522b-307c-4ee1-ac33-38072e3cfbe7	Tissu Cartilagineux (Cartilage Hyalin)	classe_07	Tissu conjonctif semi-rigide et avasculaire constitue de chondrocytes loges dans des chondroplastes au sein d'une matrice riche en collagene II et proteoglycanes.	Soutien elastique des voies respiratoires, glissement articulaire sans friction et matrice de formation du squelette embryonnaire.
732c7894-b45f-482b-af2b-5e8c2b0f4037	Tissu Osseux (Os Compact & Trabeculaire)	classe_08	Tissu conjonctif hautement mineralise organise en osteons lamellaires (systemes de Havers) parcourus de canaux vasculaires et renfermant des osteocytes.	Charpente rigide du corps, protection des organes nobles, levier locomoteur et reservoir de calcium et phosphate.
\.


--
-- Data for Name: Utilisateurs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Utilisateurs" ("Id", "Nom", "Prenom", "Email", "MotDePasseHash", "Role", "DateCreation", "EstActif", "Apogee", "GroupeTp") FROM stdin;
11111111-1111-1111-1111-111111111111	Professeur	Admin	prof@ensat.ma	$2b$11$fTfL/3IcR68yUcqCVNivY.8nKLeWOCllsI883yEfIhdac84w5XFHO	Professeur	2026-08-24 00:00:00+00	t	\N	\N
a8876c82-beb7-428b-b8a6-33b2a82e0b44	EL FASSI	Amine	elfassi.amine@etu.uae.ac.ma	$2a$11$3vJG2nWxvFmhDLCbysZQceImYKdcVAHVRA4iets7oM03mxL/nWVFS	Etudiant	2026-09-02 20:54:21.547837+00	t	21001126	G2
6eb18217-4b76-4a50-857d-462d5a3701dd	DAHBI	Khadija	dahbi.khadija@etu.uae.ac.ma	$2a$11$zzM1g4fTEgjkMV.QUPSYyOVmCCvuDyQcO.OS.8bebSoR/0gR073kK	Etudiant	2026-09-02 20:54:20.134044+00	t	21001125	G2
ef647f5e-53f3-4822-ac15-c3dc4dc3308d	CHRAIBI	Omar	chraibi.omar@etu.uae.ac.ma	$2a$11$dFxTTN1APqukfuuOfnCuYOaUDSN05PeOnzpibTR8SWM8W9ZLZLdwa	Etudiant	2026-09-02 20:54:17.870122+00	t	21001124	G1
2550a91a-bce9-4e8b-a384-86d58ee27e0b	BENNANI	Sara	bennani.sara@etu.uae.ac.ma	$2a$11$Wr7JyLJvuR7v6Nx8FpOKD.LnaoQGxBTxWh4BrzRMAGTIpR4NRORvO	Etudiant	2026-09-02 20:54:16.192467+00	t	21001123	G1
5d034761-dac3-422c-878a-2f4588692d4a	ALAMI	Youssef	alami.youssef@etu.uae.ac.ma	$2a$11$Cxwg96MLk.IVKNpIfX2rbebgZhM660xezRFsQ8dZNtVE1YK1aEMF2	Etudiant	2026-09-02 20:54:13.532434+00	t	21001122	G1
f80d5fe6-889f-4c27-b3bc-c0def887e69e	EL HADRI	Mohamed Yassine	elhadri.mohamedyassine@etu.uae.ac.ma	$2a$11$Fprp8TEkOTAOvazT2PiKreg5xSeRtR3C0Dtz/aBWp8KRAqKqQElBC	Etudiant	2026-09-02 21:31:32.028761+00	t	22015678	G1
a848a53c-7077-4d82-b2a7-fa1b6a5f12df	BEN ABDELLAH	Mosab	benabdellah.mosab@etu.uae.ac.ma	$2a$11$WeZtfPXAaw0p0VkRXVgfMuG/ZcVQY.D4W6HrPYq15mdDCu7/w3TKW	Etudiant	2026-09-02 21:31:34.836963+00	t	21009952	G1
3b699565-9487-4b62-ae70-90ed89f284cd	jdia	somia	jdia.somia@etu.uae.ac.ma	$2a$11$PztSfZ9oUp3Zrz/lemcRneAdmV7kXjAvTWH6Bmzz.1R7x8IJV/K06	Etudiant	2026-09-02 21:31:37.805236+00	t	23013601	G2
\.


--
-- Data for Name: __EFMigrationsHistory; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."__EFMigrationsHistory" ("MigrationId", "ProductVersion") FROM stdin;
20260824170717_InitialCreate	10.0.11
20260824173917_SeedUser	10.0.11
20260824195125_SeedTissus	10.0.11
20260826221654_BcryptAndNewFeatures	10.0.11
20260827111240_AddEstActifToUtilisateur	10.0.11
20260902204247_AddGroupeTpAndApogeeToUtilisateur	10.0.11
\.


--
-- Name: Choix PK_Choix; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Choix"
    ADD CONSTRAINT "PK_Choix" PRIMARY KEY ("Id");


--
-- Name: Organes PK_Organes; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Organes"
    ADD CONSTRAINT "PK_Organes" PRIMARY KEY ("Id");


--
-- Name: Questions PK_Questions; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Questions"
    ADD CONSTRAINT "PK_Questions" PRIMARY KEY ("Id");


--
-- Name: ResultatsQCM PK_ResultatsQCM; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ResultatsQCM"
    ADD CONSTRAINT "PK_ResultatsQCM" PRIMARY KEY ("Id");


--
-- Name: Scans PK_Scans; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Scans"
    ADD CONSTRAINT "PK_Scans" PRIMARY KEY ("Id");


--
-- Name: TissuOrganes PK_TissuOrganes; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."TissuOrganes"
    ADD CONSTRAINT "PK_TissuOrganes" PRIMARY KEY ("TissuId", "OrganeId");


--
-- Name: Tissus PK_Tissus; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Tissus"
    ADD CONSTRAINT "PK_Tissus" PRIMARY KEY ("Id");


--
-- Name: Utilisateurs PK_Utilisateurs; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Utilisateurs"
    ADD CONSTRAINT "PK_Utilisateurs" PRIMARY KEY ("Id");


--
-- Name: __EFMigrationsHistory PK___EFMigrationsHistory; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."__EFMigrationsHistory"
    ADD CONSTRAINT "PK___EFMigrationsHistory" PRIMARY KEY ("MigrationId");


--
-- Name: IX_Choix_QuestionId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_Choix_QuestionId" ON public."Choix" USING btree ("QuestionId");


--
-- Name: IX_Questions_TissuId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_Questions_TissuId" ON public."Questions" USING btree ("TissuId");


--
-- Name: IX_ResultatsQCM_ScanId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_ResultatsQCM_ScanId" ON public."ResultatsQCM" USING btree ("ScanId");


--
-- Name: IX_ResultatsQCM_UtilisateurId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_ResultatsQCM_UtilisateurId" ON public."ResultatsQCM" USING btree ("UtilisateurId");


--
-- Name: IX_Scans_TissuId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_Scans_TissuId" ON public."Scans" USING btree ("TissuId");


--
-- Name: IX_Scans_UtilisateurId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_Scans_UtilisateurId" ON public."Scans" USING btree ("UtilisateurId");


--
-- Name: IX_TissuOrganes_OrganeId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_TissuOrganes_OrganeId" ON public."TissuOrganes" USING btree ("OrganeId");


--
-- Name: IX_Tissus_CodeLabelIa; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IX_Tissus_CodeLabelIa" ON public."Tissus" USING btree ("CodeLabelIa");


--
-- Name: IX_Utilisateurs_Email; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IX_Utilisateurs_Email" ON public."Utilisateurs" USING btree ("Email");


--
-- Name: Choix FK_Choix_Questions_QuestionId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Choix"
    ADD CONSTRAINT "FK_Choix_Questions_QuestionId" FOREIGN KEY ("QuestionId") REFERENCES public."Questions"("Id") ON DELETE CASCADE;


--
-- Name: Questions FK_Questions_Tissus_TissuId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Questions"
    ADD CONSTRAINT "FK_Questions_Tissus_TissuId" FOREIGN KEY ("TissuId") REFERENCES public."Tissus"("Id") ON DELETE CASCADE;


--
-- Name: ResultatsQCM FK_ResultatsQCM_Scans_ScanId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ResultatsQCM"
    ADD CONSTRAINT "FK_ResultatsQCM_Scans_ScanId" FOREIGN KEY ("ScanId") REFERENCES public."Scans"("Id") ON DELETE CASCADE;


--
-- Name: ResultatsQCM FK_ResultatsQCM_Utilisateurs_UtilisateurId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ResultatsQCM"
    ADD CONSTRAINT "FK_ResultatsQCM_Utilisateurs_UtilisateurId" FOREIGN KEY ("UtilisateurId") REFERENCES public."Utilisateurs"("Id") ON DELETE CASCADE;


--
-- Name: Scans FK_Scans_Tissus_TissuId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Scans"
    ADD CONSTRAINT "FK_Scans_Tissus_TissuId" FOREIGN KEY ("TissuId") REFERENCES public."Tissus"("Id") ON DELETE RESTRICT;


--
-- Name: Scans FK_Scans_Utilisateurs_UtilisateurId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Scans"
    ADD CONSTRAINT "FK_Scans_Utilisateurs_UtilisateurId" FOREIGN KEY ("UtilisateurId") REFERENCES public."Utilisateurs"("Id") ON DELETE CASCADE;


--
-- Name: TissuOrganes FK_TissuOrganes_Organes_OrganeId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."TissuOrganes"
    ADD CONSTRAINT "FK_TissuOrganes_Organes_OrganeId" FOREIGN KEY ("OrganeId") REFERENCES public."Organes"("Id") ON DELETE CASCADE;


--
-- Name: TissuOrganes FK_TissuOrganes_Tissus_TissuId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."TissuOrganes"
    ADD CONSTRAINT "FK_TissuOrganes_Tissus_TissuId" FOREIGN KEY ("TissuId") REFERENCES public."Tissus"("Id") ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict ib9FN15BF8bRflxRzOoInmVoJm0Sys9MoNS4hZ7GZJN0XojPWqevcPTgQgf93Zr

