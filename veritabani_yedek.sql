--
-- PostgreSQL database dump
--

\restrict DqFcUek8DsclYDOSOyaRzc45FcgDPCqMzbFsSD05gmoJbKqm9Dn5fxd2lzFvMLV

-- Dumped from database version 16.14 (Ubuntu 16.14-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 16.14 (Ubuntu 16.14-0ubuntu0.24.04.1)

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

--
-- Name: DocumentType; Type: TYPE; Schema: public; Owner: sinavsistemi_admin
--

CREATE TYPE public."DocumentType" AS ENUM (
    'EXAM_PDF',
    'SOLUTION_PDF',
    'OTHER'
);


ALTER TYPE public."DocumentType" OWNER TO sinavsistemi_admin;

--
-- Name: Role; Type: TYPE; Schema: public; Owner: sinavsistemi_admin
--

CREATE TYPE public."Role" AS ENUM (
    'STUDENT',
    'EDITOR',
    'ADMIN',
    'ASISTAN',
    'SUPERADMIN',
    'MUHASEBE'
);


ALTER TYPE public."Role" OWNER TO sinavsistemi_admin;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: Document; Type: TABLE; Schema: public; Owner: sinavsistemi_admin
--

CREATE TABLE public."Document" (
    id text NOT NULL,
    name text NOT NULL,
    url text NOT NULL,
    type public."DocumentType" DEFAULT 'EXAM_PDF'::public."DocumentType" NOT NULL,
    tags text,
    "sizeBytes" integer,
    "institutionId" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "academicYear" text,
    category text,
    description text,
    title text
);


ALTER TABLE public."Document" OWNER TO sinavsistemi_admin;

--
-- Name: Exam; Type: TABLE; Schema: public; Owner: sinavsistemi_admin
--

CREATE TABLE public."Exam" (
    id text NOT NULL,
    title text NOT NULL,
    description text,
    "pdfUrl" text NOT NULL,
    "solutionPdfUrl" text,
    "startTime" timestamp(3) without time zone,
    "endTime" timestamp(3) without time zone,
    "showResultsTime" timestamp(3) without time zone,
    "questionCount" integer NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "isResultsPublished" boolean DEFAULT false NOT NULL,
    "virtualTotalParticipants" integer,
    "baseScore" double precision DEFAULT 100 NOT NULL,
    "penaltyRatio" double precision DEFAULT 0.25 NOT NULL,
    sections jsonb DEFAULT '[]'::jsonb,
    "durationMinutes" integer,
    "isActive" boolean DEFAULT true NOT NULL,
    "examTemplate" text DEFAULT 'CUSTOM'::text NOT NULL,
    "institutionId" text,
    "packageId" text,
    "sessionType" text DEFAULT 'STANDART'::text NOT NULL
);


ALTER TABLE public."Exam" OWNER TO sinavsistemi_admin;

--
-- Name: ExamPackage; Type: TABLE; Schema: public; Owner: sinavsistemi_admin
--

CREATE TABLE public."ExamPackage" (
    id text NOT NULL,
    title text NOT NULL,
    description text,
    "isActive" boolean DEFAULT true NOT NULL,
    "isSequential" boolean DEFAULT false NOT NULL,
    "institutionId" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "showResultsTime" timestamp(3) without time zone
);


ALTER TABLE public."ExamPackage" OWNER TO sinavsistemi_admin;

--
-- Name: ExamResult; Type: TABLE; Schema: public; Owner: sinavsistemi_admin
--

CREATE TABLE public."ExamResult" (
    id text NOT NULL,
    "examId" text NOT NULL,
    "userId" text NOT NULL,
    score double precision DEFAULT 0 NOT NULL,
    "correctCount" integer DEFAULT 0 NOT NULL,
    "wrongCount" integer DEFAULT 0 NOT NULL,
    "emptyCount" integer DEFAULT 0 NOT NULL,
    "isFinished" boolean DEFAULT false NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    drawings jsonb
);


ALTER TABLE public."ExamResult" OWNER TO sinavsistemi_admin;

--
-- Name: Group; Type: TABLE; Schema: public; Owner: sinavsistemi_admin
--

CREATE TABLE public."Group" (
    id text NOT NULL,
    name text NOT NULL,
    description text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "expireAt" timestamp(3) without time zone,
    "isActive" boolean DEFAULT true NOT NULL,
    price double precision DEFAULT 0 NOT NULL,
    "institutionId" text,
    "parentId" text
);


ALTER TABLE public."Group" OWNER TO sinavsistemi_admin;

--
-- Name: Institution; Type: TABLE; Schema: public; Owner: sinavsistemi_admin
--

CREATE TABLE public."Institution" (
    id text NOT NULL,
    name text NOT NULL,
    subdomain text,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."Institution" OWNER TO sinavsistemi_admin;

--
-- Name: PackageResult; Type: TABLE; Schema: public; Owner: sinavsistemi_admin
--

CREATE TABLE public."PackageResult" (
    id text NOT NULL,
    "packageId" text NOT NULL,
    "userId" text NOT NULL,
    scores jsonb,
    "isComputed" boolean DEFAULT false NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."PackageResult" OWNER TO sinavsistemi_admin;

--
-- Name: QuestionKey; Type: TABLE; Schema: public; Owner: sinavsistemi_admin
--

CREATE TABLE public."QuestionKey" (
    id text NOT NULL,
    "examId" text NOT NULL,
    "questionNumber" integer NOT NULL,
    "correctOption" text NOT NULL,
    topic text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    points double precision DEFAULT 1 NOT NULL,
    "videoUrl" text
);


ALTER TABLE public."QuestionKey" OWNER TO sinavsistemi_admin;

--
-- Name: SecurityLog; Type: TABLE; Schema: public; Owner: sinavsistemi_admin
--

CREATE TABLE public."SecurityLog" (
    id text NOT NULL,
    "examId" text NOT NULL,
    "userId" text NOT NULL,
    "actionType" text NOT NULL,
    details text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."SecurityLog" OWNER TO sinavsistemi_admin;

--
-- Name: StudentAnswer; Type: TABLE; Schema: public; Owner: sinavsistemi_admin
--

CREATE TABLE public."StudentAnswer" (
    id text NOT NULL,
    "resultId" text NOT NULL,
    "questionNumber" integer NOT NULL,
    "selectedOption" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."StudentAnswer" OWNER TO sinavsistemi_admin;

--
-- Name: Transaction; Type: TABLE; Schema: public; Owner: sinavsistemi_admin
--

CREATE TABLE public."Transaction" (
    id text NOT NULL,
    "userId" text NOT NULL,
    amount double precision NOT NULL,
    reason text NOT NULL,
    "groupId" text,
    "examId" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "institutionId" text
);


ALTER TABLE public."Transaction" OWNER TO sinavsistemi_admin;

--
-- Name: User; Type: TABLE; Schema: public; Owner: sinavsistemi_admin
--

CREATE TABLE public."User" (
    id text NOT NULL,
    email text NOT NULL,
    password text NOT NULL,
    role public."Role" DEFAULT 'STUDENT'::public."Role" NOT NULL,
    name text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "isActive" boolean DEFAULT true NOT NULL,
    phone text,
    "institutionId" text
);


ALTER TABLE public."User" OWNER TO sinavsistemi_admin;

--
-- Name: _DirectExams; Type: TABLE; Schema: public; Owner: sinavsistemi_admin
--

CREATE TABLE public."_DirectExams" (
    "A" text NOT NULL,
    "B" text NOT NULL
);


ALTER TABLE public."_DirectExams" OWNER TO sinavsistemi_admin;

--
-- Name: _ExamPackageToGroup; Type: TABLE; Schema: public; Owner: sinavsistemi_admin
--

CREATE TABLE public."_ExamPackageToGroup" (
    "A" text NOT NULL,
    "B" text NOT NULL
);


ALTER TABLE public."_ExamPackageToGroup" OWNER TO sinavsistemi_admin;

--
-- Name: _ExamToGroup; Type: TABLE; Schema: public; Owner: sinavsistemi_admin
--

CREATE TABLE public."_ExamToGroup" (
    "A" text NOT NULL,
    "B" text NOT NULL
);


ALTER TABLE public."_ExamToGroup" OWNER TO sinavsistemi_admin;

--
-- Name: _UserGroups; Type: TABLE; Schema: public; Owner: sinavsistemi_admin
--

CREATE TABLE public."_UserGroups" (
    "A" text NOT NULL,
    "B" text NOT NULL
);


ALTER TABLE public."_UserGroups" OWNER TO sinavsistemi_admin;

--
-- Name: _prisma_migrations; Type: TABLE; Schema: public; Owner: sinavsistemi_admin
--

CREATE TABLE public._prisma_migrations (
    id character varying(36) NOT NULL,
    checksum character varying(64) NOT NULL,
    finished_at timestamp with time zone,
    migration_name character varying(255) NOT NULL,
    logs text,
    rolled_back_at timestamp with time zone,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    applied_steps_count integer DEFAULT 0 NOT NULL
);


ALTER TABLE public._prisma_migrations OWNER TO sinavsistemi_admin;

--
-- Data for Name: Document; Type: TABLE DATA; Schema: public; Owner: sinavsistemi_admin
--

COPY public."Document" (id, name, url, type, tags, "sizeBytes", "institutionId", "createdAt", "updatedAt", "academicYear", category, description, title) FROM stdin;
cmp1puvqj0000hkplztgeyko0	2021_KPSS_Lisans_GYGK.pdf	/uploads/1778535065606-arsiv-2021_KPSS_Lisans_GYGK.pdf	EXAM_PDF	test	3614625	\N	2026-05-11 21:31:05.899	2026-05-11 21:31:05.899	\N	\N	\N	\N
cmp1pv7e50001hkplidp131fv	2025022301Bi70000018_24-04-2026 14_31.pdf	/uploads/1778535081002-arsiv-2025022301Bi70000018_24-04-2026-14_31.pdf	SOLUTION_PDF	testt	50471	\N	2026-05-11 21:31:21.004	2026-05-11 21:31:21.004	\N	\N	\N	\N
cmp45g60600pqhk44wqsn02c3	5. Baskı_HUKUK 4T 10'LU ALAN DENEMELERİ-1.pdf	/uploads/1778682185344-sinav-5.-Bask-_HUKUK-4T-10-LU-ALAN-DENEMELERI--1.pdf	EXAM_PDF	\N	117580	\N	2026-05-13 14:23:05.421	2026-05-13 14:23:05.421	\N	\N	\N	\N
cmp45g62d00prhk44hlagkml3	5. Baskı_HUKUK 4T 10'LU ALAN DENEMELERİ-ÇÖZÜM 1.pdf	/uploads/1778682185652-cozum-5.-Bask-_HUKUK-4T-10-LU-ALAN-DENEMELERI----Z-M-1.pdf	SOLUTION_PDF	\N	153843	\N	2026-05-13 14:23:05.653	2026-05-13 14:23:05.653	\N	\N	\N	\N
cmp46om9500s1hk44yp5ujlcp	5. Baskı_İKTİSAT 4T 10'LU ALAN DENEMELERİ-1.pdf	/uploads/1778684259219-sinav-5.-Bask-_I-KTI-SAT-4T-10-LU-ALAN-DENEMELERI--1.pdf	EXAM_PDF	\N	160911	\N	2026-05-13 14:57:39.35	2026-05-13 14:57:39.35	\N	\N	\N	\N
cmp46omd900s2hk44li8ces6j	5. Baskı_İKTİSAT 4T 10'LU ALAN DENEMELERİ-ÇÖZÜM 1.pdf	/uploads/1778684259590-cozum-5.-Bask-_I-KTI-SAT-4T-10-LU-ALAN-DENEMELERI----Z-M-1.pdf	SOLUTION_PDF	\N	502294	\N	2026-05-13 14:57:39.628	2026-05-13 14:57:39.628	\N	\N	\N	\N
cmp5j8xux0000hknt53zbwz53	5. Baskı_MALİYE 4T 10'LU ALAN DENEMELERİ-1.pdf	/uploads/1778765828965-sinav-5.-Bask-_MALI-YE-4T-10-LU-ALAN-DENEMELERI--1.pdf	EXAM_PDF	\N	108523	\N	2026-05-14 13:37:09.225	2026-05-14 13:37:09.225	\N	\N	\N	\N
cmp5j8xvb0001hknte3vjae5h	5. Baskı_MALİYE 4T 10'LU ALAN DENEMELERİ-ÇÖZÜM 1.pdf	/uploads/1778765829237-cozum-5.-Bask-_MALI-YE-4T-10-LU-ALAN-DENEMELERI----Z-M-1.pdf	SOLUTION_PDF	\N	133588	\N	2026-05-14 13:37:09.24	2026-05-14 13:37:09.24	\N	\N	\N	\N
cmp5jiu1x0017hknt543zlrpm	6. Baskı_MUHASEBE 4T 10'LU ALAN DENEMELERİ-1.pdf	/uploads/1778766290796-sinav-6.-Bask-_MUHASEBE-4T-10-LU-ALAN-DENEMELERI--1.pdf	EXAM_PDF	\N	115806	\N	2026-05-14 13:44:50.801	2026-05-14 13:44:50.801	\N	\N	\N	\N
cmp5jiu290018hknt43g590gq	6. Baskı_MUHASEBE 4T 10'LU ALAN DENEMELERİ-ÇÖZÜM 1.pdf	/uploads/1778766290863-cozum-6.-Bask-_MUHASEBE-4T-10-LU-ALAN-DENEMELERI----Z-M-1.pdf	SOLUTION_PDF	\N	153880	\N	2026-05-14 13:44:50.865	2026-05-14 13:44:50.865	\N	\N	\N	\N
cmp5lv3p2002ehknt2rmk0i6o	3. BASKI - 1 SORU KPSS B 10'LU DENEME.pdf	/uploads/1778770222378-sinav-3.-BASKI---1-SORU-KPSS-B-10-LU-DENEME.pdf	EXAM_PDF	\N	1032780	\N	2026-05-14 14:50:22.394	2026-05-14 14:50:22.394	\N	\N	\N	\N
cmp5lv3pj002fhkntyqjb8lvw	3. BASKI - 1 ÇÖZÜM KPSS B 10'LU DENEME.pdf	/uploads/1778770222467-cozum-3.-BASKI---1---Z-M-KPSS-B-10-LU-DENEME.pdf	SOLUTION_PDF	\N	1045250	\N	2026-05-14 14:50:22.471	2026-05-14 14:50:22.471	\N	\N	\N	\N
cmp8casip00xihk5djyjb6k2v	3. BASKI - 1 SORU KPSS B 10'LU DENEME.pdf	/uploads/1778935556745-sinav-3.-BASKI---1-SORU-KPSS-B-10-LU-DENEME.pdf	EXAM_PDF	\N	1032780	\N	2026-05-16 12:45:56.783	2026-05-16 12:45:56.783	\N	\N	\N	\N
cmp8casjf00xjhk5dsnr6lpo3	3. BASKI - 1 ÇÖZÜM KPSS B 10'LU DENEME.pdf	/uploads/1778935556853-cozum-3.-BASKI---1---Z-M-KPSS-B-10-LU-DENEME.pdf	SOLUTION_PDF	\N	1045250	\N	2026-05-16 12:45:56.859	2026-05-16 12:45:56.859	\N	\N	\N	\N
cmpceaysf0000hkdzsjrya7q1	5. Baskı_HUKUK 4T 10'LU ALAN DENEMELERİ-2.pdf	/uploads/1779180788601-sinav-5.-Bask-_HUKUK-4T-10-LU-ALAN-DENEMELERI--2.pdf	EXAM_PDF	\N	115177	\N	2026-05-19 08:53:08.895	2026-05-19 08:53:08.895	\N	\N	\N	\N
cmpceayud0001hkdzmbf6aza6	5. Baskı_HUKUK 4T 10'LU ALAN DENEMELERİ-ÇÖZÜM 2.pdf	/uploads/1779180788957-cozum-5.-Bask-_HUKUK-4T-10-LU-ALAN-DENEMELERI----Z-M-2.pdf	SOLUTION_PDF	\N	137742	\N	2026-05-19 08:53:08.966	2026-05-19 08:53:08.966	\N	\N	\N	\N
cmpceha61002bhkdzm39ks6rn	5. Baskı_İKTİSAT 4T 10'LU ALAN DENEMELERİ-2.pdf	/uploads/1779181083569-sinav-5.-Bask-_I-KTI-SAT-4T-10-LU-ALAN-DENEMELERI--2.pdf	EXAM_PDF	\N	123183	\N	2026-05-19 08:58:03.575	2026-05-19 08:58:03.575	\N	\N	\N	\N
cmpceha6b002chkdzv3jsremt	5. Baskı_İKTİSAT 4T 10'LU ALAN DENEMELERİ-ÇÖZÜM 2.pdf	/uploads/1779181083584-cozum-5.-Bask-_I-KTI-SAT-4T-10-LU-ALAN-DENEMELERI----Z-M-2.pdf	SOLUTION_PDF	\N	377159	\N	2026-05-19 08:58:03.587	2026-05-19 08:58:03.587	\N	\N	\N	\N
cmpcemfcs003ihkdz7c0i629w	5. Baskı_MALİYE 4T 10'LU ALAN DENEMELERİ-2.pdf	/uploads/1779181323523-sinav-5.-Bask-_MALI-YE-4T-10-LU-ALAN-DENEMELERI--2.pdf	EXAM_PDF	\N	133777	\N	2026-05-19 09:02:03.53	2026-05-19 09:02:03.53	\N	\N	\N	\N
cmpcemfd4003jhkdzxrxo7wvu	5. Baskı_MALİYE 4T 10'LU ALAN DENEMELERİ-ÇÖZÜM 2.pdf	/uploads/1779181323591-cozum-5.-Bask-_MALI-YE-4T-10-LU-ALAN-DENEMELERI----Z-M-2.pdf	SOLUTION_PDF	\N	133225	\N	2026-05-19 09:02:03.593	2026-05-19 09:02:03.593	\N	\N	\N	\N
cmpceulaf004phkdzypql8hyb	6. Baskı_MUHASEBE 4T 10'LU ALAN DENEMELERİ-2.pdf	/uploads/1779181704462-sinav-6.-Bask-_MUHASEBE-4T-10-LU-ALAN-DENEMELERI--2.pdf	EXAM_PDF	\N	114122	\N	2026-05-19 09:08:24.467	2026-05-19 09:08:24.467	\N	\N	\N	\N
cmpceulau004qhkdzr7bihqfu	6. Baskı_MUHASEBE 4T 10'LU ALAN DENEMELERİ-ÇÖZÜM 2.pdf	/uploads/1779181704532-cozum-6.-Bask-_MUHASEBE-4T-10-LU-ALAN-DENEMELERI----Z-M-2.pdf	SOLUTION_PDF	\N	133907	\N	2026-05-19 09:08:24.534	2026-05-19 09:08:24.534	\N	\N	\N	\N
cmpcf6a47005whkdz3v2cc3lr	5. Baskı_HUKUK 4T 10'LU ALAN DENEMELERİ-3.pdf	/uploads/1779182249868-sinav-5.-Bask-_HUKUK-4T-10-LU-ALAN-DENEMELERI--3.pdf	EXAM_PDF	\N	115237	\N	2026-05-19 09:17:29.873	2026-05-19 09:17:29.873	\N	\N	\N	\N
cmpcf6a4m005xhkdzqtaozqqc	5. Baskı_HUKUK 4T 10'LU ALAN DENEMELERİ-ÇÖZÜM 3.pdf	/uploads/1779182249924-cozum-5.-Bask-_HUKUK-4T-10-LU-ALAN-DENEMELERI----Z-M-3.pdf	SOLUTION_PDF	\N	132034	\N	2026-05-19 09:17:29.927	2026-05-19 09:17:29.927	\N	\N	\N	\N
cmpcfd9id0087hkdzw6xmf7e4	5. Baskı_İKTİSAT 4T 10'LU ALAN DENEMELERİ-3.pdf	/uploads/1779182575634-sinav-5.-Bask-_I-KTI-SAT-4T-10-LU-ALAN-DENEMELERI--3.pdf	EXAM_PDF	\N	126654	\N	2026-05-19 09:22:55.669	2026-05-19 09:22:55.669	\N	\N	\N	\N
cmpcfd9ip0088hkdzcxhinc8j	5. Baskı_İKTİSAT 4T 10'LU ALAN DENEMELERİ-ÇÖZÜM 3.pdf	/uploads/1779182575728-cozum-5.-Bask-_I-KTI-SAT-4T-10-LU-ALAN-DENEMELERI----Z-M-3.pdf	SOLUTION_PDF	\N	338274	\N	2026-05-19 09:22:55.73	2026-05-19 09:22:55.73	\N	\N	\N	\N
cmpcfmqa200bmhkdzo5j3ifmi	5. Baskı_MALİYE 4T 10'LU ALAN DENEMELERİ-3.pdf	/uploads/1779183017318-sinav-5.-Bask-_MALI-YE-4T-10-LU-ALAN-DENEMELERI--3.pdf	EXAM_PDF	\N	107765	\N	2026-05-19 09:30:17.322	2026-05-19 09:30:17.322	\N	\N	\N	\N
cmpcfmqab00bnhkdzfuz9si59	5. Baskı_MALİYE 4T 10'LU ALAN DENEMELERİ-ÇÖZÜM 3.pdf	/uploads/1779183017362-cozum-5.-Bask-_MALI-YE-4T-10-LU-ALAN-DENEMELERI----Z-M-3.pdf	SOLUTION_PDF	\N	138202	\N	2026-05-19 09:30:17.364	2026-05-19 09:30:17.364	\N	\N	\N	\N
cmpcfzz8700q5hkdzej73j5nn	6. Baskı_MUHASEBE 4T 10'LU ALAN DENEMELERİ-3.pdf	/uploads/1779183635446-sinav-6.-Bask-_MUHASEBE-4T-10-LU-ALAN-DENEMELERI--3.pdf	EXAM_PDF	\N	112604	\N	2026-05-19 09:40:35.451	2026-05-19 09:40:35.451	\N	\N	\N	\N
cmpcfzz8l00q6hkdzsdsyonbk	6. Baskı_MUHASEBE 4T 10'LU ALAN DENEMELERİ-ÇÖZÜM 3.pdf	/uploads/1779183635491-cozum-6.-Bask-_MUHASEBE-4T-10-LU-ALAN-DENEMELERI----Z-M-3.pdf	SOLUTION_PDF	\N	134483	\N	2026-05-19 09:40:35.493	2026-05-19 09:40:35.493	\N	\N	\N	\N
cmpch8fbq00rchkdz55jvxm7v	5. Baskı_HUKUK 4T 10'LU ALAN DENEMELERİ-4.pdf	/uploads/1779185709151-sinav-5.-Bask-_HUKUK-4T-10-LU-ALAN-DENEMELERI--4.pdf	EXAM_PDF	\N	113541	\N	2026-05-19 10:15:09.156	2026-05-19 10:15:09.156	\N	\N	\N	\N
cmpch8fc600rdhkdz76dzewrj	5. Baskı_HUKUK 4T 10'LU ALAN DENEMELERİ-ÇÖZÜM 4.pdf	/uploads/1779185709220-cozum-5.-Bask-_HUKUK-4T-10-LU-ALAN-DENEMELERI----Z-M-4.pdf	SOLUTION_PDF	\N	144111	\N	2026-05-19 10:15:09.222	2026-05-19 10:15:09.222	\N	\N	\N	\N
cmpcirzf900tnhkdz93wiq74z	5. Baskı_İKTİSAT 4T 10'LU ALAN DENEMELERİ-4.pdf	/uploads/1779188301301-sinav-5.-Bask-_I-KTI-SAT-4T-10-LU-ALAN-DENEMELERI--4.pdf	EXAM_PDF	\N	123754	\N	2026-05-19 10:58:21.307	2026-05-19 10:58:21.307	\N	\N	\N	\N
cmpcirzfl00tohkdzdf5q4jkh	5. Baskı_İKTİSAT 4T 10'LU ALAN DENEMELERİ-ÇÖZÜM 4.pdf	/uploads/1779188301343-cozum-5.-Bask-_I-KTI-SAT-4T-10-LU-ALAN-DENEMELERI----Z-M-4.pdf	SOLUTION_PDF	\N	508030	\N	2026-05-19 10:58:21.345	2026-05-19 10:58:21.345	\N	\N	\N	\N
cmpciwqpt00vyhkdztqew6446	5. Baskı_MALİYE 4T 10'LU ALAN DENEMELERİ-4.pdf	/uploads/1779188523321-sinav-5.-Bask-_MALI-YE-4T-10-LU-ALAN-DENEMELERI--4.pdf	EXAM_PDF	\N	114376	\N	2026-05-19 11:02:03.327	2026-05-19 11:02:03.327	\N	\N	\N	\N
cmpciwqq300vzhkdz834xru2k	5. Baskı_MALİYE 4T 10'LU ALAN DENEMELERİ-ÇÖZÜM 4.pdf	/uploads/1779188523337-cozum-5.-Bask-_MALI-YE-4T-10-LU-ALAN-DENEMELERI----Z-M-4.pdf	SOLUTION_PDF	\N	161783	\N	2026-05-19 11:02:03.339	2026-05-19 11:02:03.339	\N	\N	\N	\N
cmpcj8j8x00y9hkdziq7n32c8	6. Baskı_MUHASEBE 4T 10'LU ALAN DENEMELERİ-4.pdf	/uploads/1779189073485-sinav-6.-Bask-_MUHASEBE-4T-10-LU-ALAN-DENEMELERI--4.pdf	EXAM_PDF	\N	115036	\N	2026-05-19 11:11:13.489	2026-05-19 11:11:13.489	\N	\N	\N	\N
cmpcj8j9800yahkdz4t2xxfu5	6. Baskı_MUHASEBE 4T 10'LU ALAN DENEMELERİ-ÇÖZÜM 4.pdf	/uploads/1779189073530-cozum-6.-Bask-_MUHASEBE-4T-10-LU-ALAN-DENEMELERI----Z-M-4.pdf	SOLUTION_PDF	\N	162075	\N	2026-05-19 11:11:13.532	2026-05-19 11:11:13.532	\N	\N	\N	\N
cmpcmu9sy010khkdze94ba4kn	5. Baskı_HUKUK 4T 10'LU ALAN DENEMELERİ-5.pdf	/uploads/1779195126519-sinav-5.-Bask-_HUKUK-4T-10-LU-ALAN-DENEMELERI--5.pdf	EXAM_PDF	\N	118990	\N	2026-05-19 12:52:06.527	2026-05-19 12:52:06.527	\N	\N	\N	\N
cmpcmu9tc010lhkdzswd9151v	5. Baskı_HUKUK 4T 10'LU ALAN DENEMELERİ-ÇÖZÜM 5.pdf	/uploads/1779195126573-cozum-5.-Bask-_HUKUK-4T-10-LU-ALAN-DENEMELERI----Z-M-5.pdf	SOLUTION_PDF	\N	133644	\N	2026-05-19 12:52:06.576	2026-05-19 12:52:06.576	\N	\N	\N	\N
cmpcmzxs3012vhkdzxqkrird9	5. Baskı_İKTİSAT 4T 10'LU ALAN DENEMELERİ-5.pdf	/uploads/1779195390906-sinav-5.-Bask-_I-KTI-SAT-4T-10-LU-ALAN-DENEMELERI--5.pdf	EXAM_PDF	\N	127244	\N	2026-05-19 12:56:30.912	2026-05-19 12:56:30.912	\N	\N	\N	\N
cmpcmzxse012whkdzyynem69q	5. Baskı_İKTİSAT 4T 10'LU ALAN DENEMELERİ-ÇÖZÜM 5.pdf	/uploads/1779195390924-cozum-5.-Bask-_I-KTI-SAT-4T-10-LU-ALAN-DENEMELERI----Z-M-5.pdf	SOLUTION_PDF	\N	286046	\N	2026-05-19 12:56:30.926	2026-05-19 12:56:30.926	\N	\N	\N	\N
cmpcn4fo70156hkdzir8uhsa6	5. Baskı_MALİYE 4T 10'LU ALAN DENEMELERİ-5.pdf	/uploads/1779195600658-sinav-5.-Bask-_MALI-YE-4T-10-LU-ALAN-DENEMELERI--5.pdf	EXAM_PDF	\N	109010	\N	2026-05-19 13:00:00.663	2026-05-19 13:00:00.663	\N	\N	\N	\N
cmpcn4foh0157hkdzqurc8dew	5. Baskı_MALİYE 4T 10'LU ALAN DENEMELERİ-ÇÖZÜM 5.pdf	/uploads/1779195600735-cozum-5.-Bask-_MALI-YE-4T-10-LU-ALAN-DENEMELERI----Z-M-5.pdf	SOLUTION_PDF	\N	127817	\N	2026-05-19 13:00:00.737	2026-05-19 13:00:00.737	\N	\N	\N	\N
cmpcnbia0017hhkdz88tqf2f1	6. Baskı_MUHASEBE 4T 10'LU ALAN DENEMELERİ-5.pdf	/uploads/1779195930642-sinav-6.-Bask-_MUHASEBE-4T-10-LU-ALAN-DENEMELERI--5.pdf	EXAM_PDF	\N	111840	\N	2026-05-19 13:05:30.644	2026-05-19 13:05:30.644	\N	\N	\N	\N
cmpcnbiaa017ihkdzrws2mgrb	6. Baskı_MUHASEBE 4T 10'LU ALAN DENEMELERİ-ÇÖZÜM 5.pdf	/uploads/1779195930704-cozum-6.-Bask-_MUHASEBE-4T-10-LU-ALAN-DENEMELERI----Z-M-5.pdf	SOLUTION_PDF	\N	133273	\N	2026-05-19 13:05:30.706	2026-05-19 13:05:30.706	\N	\N	\N	\N
cmpfbgd3u0000hkzbtogof0w0	3. BASKI - 1 SORU KPSS B 10'LU DENEME.pdf	/uploads/1779357400334-sinav-3.-BASKI---1-SORU-KPSS-B-10-LU-DENEME.pdf	EXAM_PDF	\N	1032780	\N	2026-05-21 09:56:40.355	2026-05-21 09:56:40.355	\N	\N	\N	\N
cmpfbgd4d0001hkzb1s1d3t5v	3. BASKI - 1 ÇÖZÜM KPSS B 10'LU DENEME.pdf	/uploads/1779357400421-cozum-3.-BASKI---1---Z-M-KPSS-B-10-LU-DENEME.pdf	SOLUTION_PDF	\N	1045250	\N	2026-05-21 09:56:40.43	2026-05-21 09:56:40.43	\N	\N	\N	\N
cmpfexdzn01pshkzbzmymx6mc	3. BASKI - 2 SORU KPSS B 10'LU DENEME .pdf	/uploads/1779363233495-sinav-3.-BASKI---2-SORU-KPSS-B-10-LU-DENEME-.pdf	EXAM_PDF	\N	1422196	\N	2026-05-21 11:33:53.517	2026-05-21 11:33:53.517	\N	\N	\N	\N
cmpfexe0801pthkzbd7f64ux2	3. BASKI - 2 ÇÖZÜM KPSS B 10'LU DENEME.pdf	/uploads/1779363233566-cozum-3.-BASKI---2---Z-M-KPSS-B-10-LU-DENEME.pdf	SOLUTION_PDF	\N	1004160	\N	2026-05-21 11:33:53.576	2026-05-21 11:33:53.576	\N	\N	\N	\N
cmpfka7q201xohkzb28p8exwz	3. BASKI - 3 SORU KPSS B 10'LU DENEME.pdf	/uploads/1779372229991-sinav-3.-BASKI---3-SORU-KPSS-B-10-LU-DENEME.pdf	EXAM_PDF	\N	907681	\N	2026-05-21 14:03:49.999	2026-05-21 14:03:49.999	\N	\N	\N	\N
cmpfka7qo01xphkzbqlokswic	3. BASKI - 3 ÇÖZÜM KPSS B 10'LU DENEME.pdf	/uploads/1779372230062-cozum-3.-BASKI---3---Z-M-KPSS-B-10-LU-DENEME.pdf	SOLUTION_PDF	\N	971584	\N	2026-05-21 14:03:50.065	2026-05-21 14:03:50.065	\N	\N	\N	\N
cmpgmklo30000hk9k3plqipj6	3. BASKI - 4 SORU KPSS B 10'LU DENEME.pdf	/uploads/1779436540042-sinav-3.-BASKI---4-SORU-KPSS-B-10-LU-DENEME.pdf	EXAM_PDF	\N	790863	\N	2026-05-22 07:55:40.047	2026-05-22 07:55:40.047	\N	\N	\N	\N
cmpgmklq90001hk9krz35vbw6	3. BASKI - 4 ÇÖZÜM KPSS B 10'LU DENEME.pdf	/uploads/1779436540096-cozum-3.-BASKI---4---Z-M-KPSS-B-10-LU-DENEME.pdf	SOLUTION_PDF	\N	1088553	\N	2026-05-22 07:55:40.162	2026-05-22 07:55:40.162	\N	\N	\N	\N
cmpwswxat0000hkwpvyhoaxfm	3. BASKI - 5 SORU KPSS B 10'LU DENEME.pdf	/uploads/1780414651496-sinav-3.-BASKI---5-SORU-KPSS-B-10-LU-DENEME.pdf	EXAM_PDF	\N	786973	\N	2026-06-02 15:37:31.505	2026-06-02 15:37:31.505	\N	\N	\N	\N
cmpwswxc30001hkwp7xasehyq	3. BASKI - 5 ÇÖZÜM KPSS B 10'LU DENEME.pdf	/uploads/1780414651559-cozum-3.-BASKI---5---Z-M-KPSS-B-10-LU-DENEME.pdf	SOLUTION_PDF	\N	953245	\N	2026-06-02 15:37:31.588	2026-06-02 15:37:31.588	\N	\N	\N	\N
cmpwtb2wy006shkwpms5779i0	3. BASKI - 6 SORU KPSS B 10'LU DENEME.pdf	/uploads/1780415311927-sinav-3.-BASKI---6-SORU-KPSS-B-10-LU-DENEME.pdf	EXAM_PDF	\N	811235	\N	2026-06-02 15:48:31.942	2026-06-02 15:48:31.942	\N	\N	\N	\N
cmpwtb2xt006thkwpsndhphp8	3. BASKI - 6 ÇÖZÜM KPSS B 10'LU DENEME.pdf	/uploads/1780415312020-cozum-3.-BASKI---6---Z-M-KPSS-B-10-LU-DENEME.pdf	SOLUTION_PDF	\N	893587	\N	2026-06-02 15:48:32.034	2026-06-02 15:48:32.034	\N	\N	\N	\N
cmpwti7yc00a7hkwpfdxv6awq	5. Baskı_HUKUK 4T 10'LU ALAN DENEMELERİ-6.pdf	/uploads/1780415645082-sinav-5.-Bask-_HUKUK-4T-10-LU-ALAN-DENEMELERI--6.pdf	EXAM_PDF	\N	113520	\N	2026-06-02 15:54:05.087	2026-06-02 15:54:05.087	\N	\N	\N	\N
cmpwti7yk00a8hkwpnp5vk6v2	5. Baskı_HUKUK 4T 10'LU ALAN DENEMELERİ-ÇÖZÜM 6.pdf	/uploads/1780415645130-cozum-5.-Bask-_HUKUK-4T-10-LU-ALAN-DENEMELERI----Z-M-6.pdf	SOLUTION_PDF	\N	124108	\N	2026-06-02 15:54:05.132	2026-06-02 15:54:05.132	\N	\N	\N	\N
cmpwtnr2100behkwpqucqio9x	5. Baskı_İKTİSAT 4T 10'LU ALAN DENEMELERİ-6.pdf	/uploads/1780415903153-sinav-5.-Bask-_I-KTI-SAT-4T-10-LU-ALAN-DENEMELERI--6.pdf	EXAM_PDF	\N	156280	\N	2026-06-02 15:58:23.159	2026-06-02 15:58:23.159	\N	\N	\N	\N
cmpwtnr2800bfhkwpviufy8fn	5. Baskı_İKTİSAT 4T 10'LU ALAN DENEMELERİ-ÇÖZÜM 6.pdf	/uploads/1780415903165-cozum-5.-Bask-_I-KTI-SAT-4T-10-LU-ALAN-DENEMELERI----Z-M-6.pdf	SOLUTION_PDF	\N	489113	\N	2026-06-02 15:58:23.169	2026-06-02 15:58:23.169	\N	\N	\N	\N
cmpwu7wyr00clhkwpkh6sh24w	5. Baskı_MALİYE 4T 10'LU ALAN DENEMELERİ-6.pdf	/uploads/1780416843898-sinav-5.-Bask-_MALI-YE-4T-10-LU-ALAN-DENEMELERI--6.pdf	EXAM_PDF	\N	107396	\N	2026-06-02 16:14:03.903	2026-06-02 16:14:03.903	\N	\N	\N	\N
cmpwu7wz100cmhkwpt21xjp6e	5. Baskı_MALİYE 4T 10'LU ALAN DENEMELERİ-ÇÖZÜM 6.pdf	/uploads/1780416843947-cozum-5.-Bask-_MALI-YE-4T-10-LU-ALAN-DENEMELERI----Z-M-6.pdf	SOLUTION_PDF	\N	130605	\N	2026-06-02 16:14:03.949	2026-06-02 16:14:03.949	\N	\N	\N	\N
cmpwufjv200ewhkwpguk5eyet	6. Baskı_MUHASEBE 4T 10'LU ALAN DENEMELERİ-6.pdf	/uploads/1780417200164-sinav-6.-Bask-_MUHASEBE-4T-10-LU-ALAN-DENEMELERI--6.pdf	EXAM_PDF	\N	114783	\N	2026-06-02 16:20:00.169	2026-06-02 16:20:00.169	\N	\N	\N	\N
cmpwufjve00exhkwpwn3ilzpk	6. Baskı_MUHASEBE 4T 10'LU ALAN DENEMELERİ-ÇÖZÜM 6.pdf	/uploads/1780417200216-cozum-6.-Bask-_MUHASEBE-4T-10-LU-ALAN-DENEMELERI----Z-M-6.pdf	SOLUTION_PDF	\N	152164	\N	2026-06-02 16:20:00.218	2026-06-02 16:20:00.218	\N	\N	\N	\N
cmpwv00sh00g4hkwp8mtk437o	3. BASKI - 7 SORU KPSS B 10'LU DENEME.pdf	/uploads/1780418155145-sinav-3.-BASKI---7-SORU-KPSS-B-10-LU-DENEME.pdf	EXAM_PDF	\N	675556	\N	2026-06-02 16:35:55.155	2026-06-02 16:35:55.155	\N	\N	\N	\N
cmpwv00sv00g5hkwp7v39pjj2	3. BASKI - 7 ÇÖZÜM KPSS B 10'LU DENEME.pdf	/uploads/1780418155277-cozum-3.-BASKI---7---Z-M-KPSS-B-10-LU-DENEME.pdf	SOLUTION_PDF	\N	890600	\N	2026-06-02 16:35:55.279	2026-06-02 16:35:55.279	\N	\N	\N	\N
cmpxrepdq0002hke62g9o86a4	5. Baskı_HUKUK 4T 10'LU ALAN DENEMELERİ-7.pdf	/uploads/1780472587974-sinav-5.-Bask-_HUKUK-4T-10-LU-ALAN-DENEMELERI--7.pdf	EXAM_PDF	\N	116779	\N	2026-06-03 07:43:07.982	2026-06-03 07:43:07.982	\N	\N	\N	\N
cmpxrepe60003hke61xaxfm8z	5. Baskı_HUKUK 4T 10'LU ALAN DENEMELERİ-ÇÖZÜM 7.pdf	/uploads/1780472588042-cozum-5.-Bask-_HUKUK-4T-10-LU-ALAN-DENEMELERI----Z-M-7.pdf	SOLUTION_PDF	\N	136193	\N	2026-06-03 07:43:08.046	2026-06-03 07:43:08.046	\N	\N	\N	\N
cmpxsd1510019hke6l9pbo2jj	5. Baskı_İKTİSAT 4T 10'LU ALAN DENEMELERİ-7.pdf	/uploads/1780474189510-sinav-5.-Bask-_I-KTI-SAT-4T-10-LU-ALAN-DENEMELERI--7.pdf	EXAM_PDF	\N	122598	\N	2026-06-03 08:09:49.52	2026-06-03 08:09:49.52	\N	\N	\N	\N
cmpxsd15i001ahke6vpeza978	5. Baskı_İKTİSAT 4T 10'LU ALAN DENEMELERİ-ÇÖZÜM 7.pdf	/uploads/1780474189586-cozum-5.-Bask-_I-KTI-SAT-4T-10-LU-ALAN-DENEMELERI----Z-M-7.pdf	SOLUTION_PDF	\N	414082	\N	2026-06-03 08:09:49.59	2026-06-03 08:09:49.59	\N	\N	\N	\N
cmpxshh7n002ghke6rzjg7u3q	5. Baskı_İKTİSAT 4T 10'LU ALAN DENEMELERİ-7.pdf	/uploads/1780474397017-sinav-5.-Bask-_I-KTI-SAT-4T-10-LU-ALAN-DENEMELERI--7.pdf	EXAM_PDF	\N	122598	\N	2026-06-03 08:13:17.024	2026-06-03 08:13:17.024	\N	\N	\N	\N
cmpxshh7x002hhke6f1gmtc5a	5. Baskı_İKTİSAT 4T 10'LU ALAN DENEMELERİ-ÇÖZÜM 7.pdf	/uploads/1780474397034-cozum-5.-Bask-_I-KTI-SAT-4T-10-LU-ALAN-DENEMELERI----Z-M-7.pdf	SOLUTION_PDF	\N	414082	\N	2026-06-03 08:13:17.037	2026-06-03 08:13:17.037	\N	\N	\N	\N
cmpxsu9qd003nhke631frtxqb	6. Baskı_MUHASEBE 4T 10'LU ALAN DENEMELERİ-7.pdf	/uploads/1780474993806-sinav-6.-Bask-_MUHASEBE-4T-10-LU-ALAN-DENEMELERI--7.pdf	EXAM_PDF	\N	112776	\N	2026-06-03 08:23:13.812	2026-06-03 08:23:13.812	\N	\N	\N	\N
cmpxsu9qt003ohke6sf8blm7t	6. Baskı_MUHASEBE 4T 10'LU ALAN DENEMELERİ-ÇÖZÜM 7.pdf	/uploads/1780474993873-cozum-6.-Bask-_MUHASEBE-4T-10-LU-ALAN-DENEMELERI----Z-M-7.pdf	SOLUTION_PDF	\N	126204	\N	2026-06-03 08:23:13.877	2026-06-03 08:23:13.877	\N	\N	\N	\N
cmpxtxasf004vhke6nm7za3nf	3. BASKI - 8 SORU KPSS B 10'LU DENEME.pdf	/uploads/1780476814777-sinav-3.-BASKI---8-SORU-KPSS-B-10-LU-DENEME.pdf	EXAM_PDF	\N	550653	\N	2026-06-03 08:53:34.782	2026-06-03 08:53:34.782	\N	\N	\N	\N
cmpxtxasq004whke6a3diig18	3. BASKI - 8 ÇÖZÜM KPSS B 10'LU DENEME.pdf	/uploads/1780476814823-cozum-3.-BASKI---8---Z-M-KPSS-B-10-LU-DENEME.pdf	SOLUTION_PDF	\N	1007430	\N	2026-06-03 08:53:34.827	2026-06-03 08:53:34.827	\N	\N	\N	\N
cmpxu82q2008ahke69d6fhgf3	5. Baskı_HUKUK 4T 10'LU ALAN DENEMELERİ-8.pdf	/uploads/1780477317525-sinav-5.-Bask-_HUKUK-4T-10-LU-ALAN-DENEMELERI--8.pdf	EXAM_PDF	\N	117239	\N	2026-06-03 09:01:57.53	2026-06-03 09:01:57.53	\N	\N	\N	\N
cmpxu82qe008bhke6mplwdboi	5. Baskı_HUKUK 4T 10'LU ALAN DENEMELERİ-ÇÖZÜM 8.pdf	/uploads/1780477317588-cozum-5.-Bask-_HUKUK-4T-10-LU-ALAN-DENEMELERI----Z-M-8.pdf	SOLUTION_PDF	\N	125637	\N	2026-06-03 09:01:57.59	2026-06-03 09:01:57.59	\N	\N	\N	\N
cmpxui50d009hhke63kby48lk	5. Baskı_İKTİSAT 4T 10'LU ALAN DENEMELERİ-8.pdf	/uploads/1780477787059-sinav-5.-Bask-_I-KTI-SAT-4T-10-LU-ALAN-DENEMELERI--8.pdf	EXAM_PDF	\N	118154	\N	2026-06-03 09:09:47.064	2026-06-03 09:09:47.064	\N	\N	\N	\N
cmpxui50m009ihke6jkc84e4i	5. Baskı_İKTİSAT 4T 10'LU ALAN DENEMELERİ-ÇÖZÜM 8.pdf	/uploads/1780477787109-cozum-5.-Bask-_I-KTI-SAT-4T-10-LU-ALAN-DENEMELERI----Z-M-8.pdf	SOLUTION_PDF	\N	356941	\N	2026-06-03 09:09:47.111	2026-06-03 09:09:47.111	\N	\N	\N	\N
cmpxumqvj00aohke6cr8q8k1l	5. Baskı_İKTİSAT 4T 10'LU ALAN DENEMELERİ-8.pdf	/uploads/1780478002054-sinav-5.-Bask-_I-KTI-SAT-4T-10-LU-ALAN-DENEMELERI--8.pdf	EXAM_PDF	\N	118154	\N	2026-06-03 09:13:22.06	2026-06-03 09:13:22.06	\N	\N	\N	\N
cmpxumqvr00aphke6lch77wnn	5. Baskı_İKTİSAT 4T 10'LU ALAN DENEMELERİ-ÇÖZÜM 8.pdf	/uploads/1780478002069-cozum-5.-Bask-_I-KTI-SAT-4T-10-LU-ALAN-DENEMELERI----Z-M-8.pdf	SOLUTION_PDF	\N	356941	\N	2026-06-03 09:13:22.072	2026-06-03 09:13:22.072	\N	\N	\N	\N
cmpxvbyc400bvhke6jgliht2g	6. Baskı_MUHASEBE 4T 10'LU ALAN DENEMELERİ-8.pdf	/uploads/1780479178076-sinav-6.-Bask-_MUHASEBE-4T-10-LU-ALAN-DENEMELERI--8.pdf	EXAM_PDF	\N	112526	\N	2026-06-03 09:32:58.082	2026-06-03 09:32:58.082	\N	\N	\N	\N
cmpxvbyck00bwhke6tzva1o13	6. Baskı_MUHASEBE 4T 10'LU ALAN DENEMELERİ-ÇÖZÜM 8.pdf	/uploads/1780479178146-cozum-6.-Bask-_MUHASEBE-4T-10-LU-ALAN-DENEMELERI----Z-M-8.pdf	SOLUTION_PDF	\N	141121	\N	2026-06-03 09:32:58.149	2026-06-03 09:32:58.149	\N	\N	\N	\N
cmpxvii3m00d3hke6kehy9clf	3. BASKI - 9 SORU KPSS B 10'LU DENEME.pdf	/uploads/1780479483620-sinav-3.-BASKI---9-SORU-KPSS-B-10-LU-DENEME.pdf	EXAM_PDF	\N	757138	\N	2026-06-03 09:38:03.626	2026-06-03 09:38:03.626	\N	\N	\N	\N
cmpxvii4500d4hke6ol5rhnpy	3. BASKI - 9 ÇÖZÜM KPSS B 10'LU DENEME.pdf	/uploads/1780479483697-cozum-3.-BASKI---9---Z-M-KPSS-B-10-LU-DENEME.pdf	SOLUTION_PDF	\N	1122945	\N	2026-06-03 09:38:03.701	2026-06-03 09:38:03.701	\N	\N	\N	\N
cmpxvuq0w00gihke611rlltdq	5. Baskı_HUKUK 4T 10'LU ALAN DENEMELERİ-9.pdf	/uploads/1780480053766-sinav-5.-Bask-_HUKUK-4T-10-LU-ALAN-DENEMELERI--9.pdf	EXAM_PDF	\N	117644	\N	2026-06-03 09:47:33.771	2026-06-03 09:47:33.771	\N	\N	\N	\N
cmpxvuq1800gjhke6xdha1ol0	5. Baskı_HUKUK 4T 10'LU ALAN DENEMELERİ-ÇÖZÜM 9.pdf	/uploads/1780480053834-cozum-5.-Bask-_HUKUK-4T-10-LU-ALAN-DENEMELERI----Z-M-9.pdf	SOLUTION_PDF	\N	138303	\N	2026-06-03 09:47:33.837	2026-06-03 09:47:33.837	\N	\N	\N	\N
cmpxvwgaw00hphke6mkg35bw8	5. Baskı_İKTİSAT 4T 10'LU ALAN DENEMELERİ-9.pdf	/uploads/1780480134532-sinav-5.-Bask-_I-KTI-SAT-4T-10-LU-ALAN-DENEMELERI--9.pdf	EXAM_PDF	\N	122643	\N	2026-06-03 09:48:54.535	2026-06-03 09:48:54.535	\N	\N	\N	\N
cmpxvwgb300hqhke6di5rkox9	5. Baskı_İKTİSAT 4T 10'LU ALAN DENEMELERİ-ÇÖZÜM 9.pdf	/uploads/1780480134541-cozum-5.-Bask-_I-KTI-SAT-4T-10-LU-ALAN-DENEMELERI----Z-M-9.pdf	SOLUTION_PDF	\N	536058	\N	2026-06-03 09:48:54.544	2026-06-03 09:48:54.544	\N	\N	\N	\N
cmpxvy55h00iwhke6j1s9e9kv	5. Baskı_MALİYE 4T 10'LU ALAN DENEMELERİ-9.pdf	/uploads/1780480213390-sinav-5.-Bask-_MALI-YE-4T-10-LU-ALAN-DENEMELERI--9.pdf	EXAM_PDF	\N	108408	\N	2026-06-03 09:50:13.394	2026-06-03 09:50:13.394	\N	\N	\N	\N
cmpxvy55o00ixhke66ppcaqc0	5. Baskı_MALİYE 4T 10'LU ALAN DENEMELERİ-ÇÖZÜM 9.pdf	/uploads/1780480213402-cozum-5.-Bask-_MALI-YE-4T-10-LU-ALAN-DENEMELERI----Z-M-9.pdf	SOLUTION_PDF	\N	128854	\N	2026-06-03 09:50:13.404	2026-06-03 09:50:13.404	\N	\N	\N	\N
cmpxw01d000k3hke6r9enj4un	6. Baskı_MUHASEBE 4T 10'LU ALAN DENEMELERİ-9.pdf	/uploads/1780480301790-sinav-6.-Bask-_MUHASEBE-4T-10-LU-ALAN-DENEMELERI--9.pdf	EXAM_PDF	\N	118209	\N	2026-06-03 09:51:41.795	2026-06-03 09:51:41.795	\N	\N	\N	\N
cmpxw01d800k4hke623bm6nzr	6. Baskı_MUHASEBE 4T 10'LU ALAN DENEMELERİ-ÇÖZÜM 9.pdf	/uploads/1780480301801-cozum-6.-Bask-_MUHASEBE-4T-10-LU-ALAN-DENEMELERI----Z-M-9.pdf	SOLUTION_PDF	\N	143396	\N	2026-06-03 09:51:41.804	2026-06-03 09:51:41.804	\N	\N	\N	\N
cmpxw4fcw00lbhke6l16a868y	3. BASKI - 10 SORU KPSS B 10'LU DENEME.pdf	/uploads/1780480506475-sinav-3.-BASKI---10-SORU-KPSS-B-10-LU-DENEME.pdf	EXAM_PDF	\N	868248	\N	2026-06-03 09:55:06.493	2026-06-03 09:55:06.493	\N	\N	\N	\N
cmpxw4fd700lchke629eegnso	3. BASKI - 10 ÇÖZÜM KPSS B 10'LU DENEME.pdf	/uploads/1780480506569-cozum-3.-BASKI---10---Z-M-KPSS-B-10-LU-DENEME.pdf	SOLUTION_PDF	\N	952049	\N	2026-06-03 09:55:06.571	2026-06-03 09:55:06.571	\N	\N	\N	\N
cmpxw5zu100oqhke67fnw3j9m	5. Baskı_HUKUK 4T 10'LU ALAN DENEMELERİ-10.pdf	/uploads/1780480579750-sinav-5.-Bask-_HUKUK-4T-10-LU-ALAN-DENEMELERI--10.pdf	EXAM_PDF	\N	120328	\N	2026-06-03 09:56:19.753	2026-06-03 09:56:19.753	\N	\N	\N	\N
cmpxw5zu700orhke6rogg02gp	5. Baskı_HUKUK 4T 10'LU ALAN DENEMELERİ-ÇÖZÜM 10.pdf	/uploads/1780480579757-cozum-5.-Bask-_HUKUK-4T-10-LU-ALAN-DENEMELERI----Z-M-10.pdf	SOLUTION_PDF	\N	146191	\N	2026-06-03 09:56:19.759	2026-06-03 09:56:19.759	\N	\N	\N	\N
cmpxw7hys00pxhke65o75ms5l	5. Baskı_İKTİSAT 4T 10'LU ALAN DENEMELERİ-10.pdf	/uploads/1780480649905-sinav-5.-Bask-_I-KTI-SAT-4T-10-LU-ALAN-DENEMELERI--10.pdf	EXAM_PDF	\N	123491	\N	2026-06-03 09:57:29.908	2026-06-03 09:57:29.908	\N	\N	\N	\N
cmpxw7hz000pyhke63bl4zwag	5. Baskı_İKTİSAT 4T 10'LU ALAN DENEMELERİ-ÇÖZÜM 10.pdf	/uploads/1780480649913-cozum-5.-Bask-_I-KTI-SAT-4T-10-LU-ALAN-DENEMELERI----Z-M-10.pdf	SOLUTION_PDF	\N	617062	\N	2026-06-03 09:57:29.916	2026-06-03 09:57:29.916	\N	\N	\N	\N
cmpxw9h0500r4hke6v96lzocc	5. Baskı_MALİYE 4T 10'LU ALAN DENEMELERİ-10.pdf	/uploads/1780480741963-sinav-5.-Bask-_MALI-YE-4T-10-LU-ALAN-DENEMELERI--10.pdf	EXAM_PDF	\N	108455	\N	2026-06-03 09:59:01.97	2026-06-03 09:59:01.97	\N	\N	\N	\N
cmpxw9h0e00r5hke65etc2rg2	5. Baskı_MALİYE 4T 10'LU ALAN DENEMELERİ-ÇÖZÜM 10.pdf	/uploads/1780480741979-cozum-5.-Bask-_MALI-YE-4T-10-LU-ALAN-DENEMELERI----Z-M-10.pdf	SOLUTION_PDF	\N	138896	\N	2026-06-03 09:59:01.982	2026-06-03 09:59:01.982	\N	\N	\N	\N
cmpxwaxwt00sbhke6hin696tx	6. Baskı_MUHASEBE 4T 10'LU ALAN DENEMELERİ-10.pdf	/uploads/1780480810492-sinav-6.-Bask-_MUHASEBE-4T-10-LU-ALAN-DENEMELERI--10.pdf	EXAM_PDF	\N	119413	\N	2026-06-03 10:00:10.494	2026-06-03 10:00:10.494	\N	\N	\N	\N
cmpxwaxx200schke63f5r9jdd	6. Baskı_MUHASEBE 4T 10'LU ALAN DENEMELERİ-ÇÖZÜM 10.pdf	/uploads/1780480810548-cozum-6.-Bask-_MUHASEBE-4T-10-LU-ALAN-DENEMELERI----Z-M-10.pdf	SOLUTION_PDF	\N	138792	\N	2026-06-03 10:00:10.551	2026-06-03 10:00:10.551	\N	\N	\N	\N
\.


--
-- Data for Name: Exam; Type: TABLE DATA; Schema: public; Owner: sinavsistemi_admin
--

COPY public."Exam" (id, title, description, "pdfUrl", "solutionPdfUrl", "startTime", "endTime", "showResultsTime", "questionCount", "createdAt", "updatedAt", "isResultsPublished", "virtualTotalParticipants", "baseScore", "penaltyRatio", sections, "durationMinutes", "isActive", "examTemplate", "institutionId", "packageId", "sessionType") FROM stdin;
cmp5j8xvh0002hkntbvhrqecu	KPSS MALİYE DENEME 1	Maliye Deneme 1	/uploads/1778765828965-sinav-5.-Bask-_MALI-YE-4T-10-LU-ALAN-DENEMELERI--1.pdf	/uploads/1778765829237-cozum-5.-Bask-_MALI-YE-4T-10-LU-ALAN-DENEMELERI----Z-M-1.pdf	2026-06-21 07:00:00	2026-09-06 07:00:00	2026-06-22 07:00:00	40	2026-05-14 13:37:09.245	2026-06-05 09:41:49.573	f	1000	0	0.25	[{"id": "1778765473292", "count": 40, "title": "MALİYE", "points": "0.20"}]	50	f	CUSTOM	\N	cmpfbt7tb006rhkzbr1k26q0j	STANDART
cmpceha6h002dhkdzrrzyzdbv	KPSS İKTİSAT DENEME 2	İktisat Deneme 2	/uploads/1779181083569-sinav-5.-Bask-_I-KTI-SAT-4T-10-LU-ALAN-DENEMELERI--2.pdf	/uploads/1779181083584-cozum-5.-Bask-_I-KTI-SAT-4T-10-LU-ALAN-DENEMELERI----Z-M-2.pdf	2026-06-28 07:00:00	2026-09-06 07:00:00	2026-06-29 07:00:00	40	2026-05-19 08:58:03.593	2026-06-05 08:52:22.179	f	1000	0	0.25	[{"id": "1779180790671", "count": 40, "title": "İktisat", "points": "0.20"}]	50	f	CUSTOM	\N	cmpfeyk3p01t7hkzbpf34p0yd	STANDART
cmpcfd9it0089hkdz1pm9fzpp	KPSS İKTİSAT DENEME 3	İktisat Deneme 3	/uploads/1779182575634-sinav-5.-Bask-_I-KTI-SAT-4T-10-LU-ALAN-DENEMELERI--3.pdf	/uploads/1779182575728-cozum-5.-Bask-_I-KTI-SAT-4T-10-LU-ALAN-DENEMELERI----Z-M-3.pdf	2026-07-05 07:00:00	2026-09-06 07:00:00	2026-07-06 07:00:00	40	2026-05-19 09:22:55.733	2026-06-05 08:57:00.898	f	1000	0	0.25	[{"id": "1779182251593", "count": 40, "title": "İktisat", "points": "0.20"}]	50	f	CUSTOM	\N	cmpfkcbpz0213hkzb7z4p2re7	STANDART
cmpcj8j9c00ybhkdzctaisitd	KPSS MUHASEBE DENEME 4	Muhasebe Deneme 4	/uploads/1779189073485-sinav-6.-Bask-_MUHASEBE-4T-10-LU-ALAN-DENEMELERI--4.pdf	/uploads/1779189073530-cozum-6.-Bask-_MUHASEBE-4T-10-LU-ALAN-DENEMELERI----Z-M-4.pdf	2026-07-12 07:00:00	2026-09-06 07:00:00	2026-07-13 07:00:00	40	2026-05-19 11:11:13.536	2026-06-05 09:19:08.647	f	1000	0	0.25	[{"id": "1779188523423", "count": 40, "title": "Genel Test", "points": "0.20"}]	50	f	CUSTOM	\N	cmpgmoa5h007vhk9k9lg24vxz	STANDART
cmpciwqq700w0hkdzjbgaqxol	KPSS MALİYE DENEME 4	Maliye Deneme 4	/uploads/1779188523321-sinav-5.-Bask-_MALI-YE-4T-10-LU-ALAN-DENEMELERI--4.pdf	/uploads/1779188523337-cozum-5.-Bask-_MALI-YE-4T-10-LU-ALAN-DENEMELERI----Z-M-4.pdf	2026-07-12 07:00:00	2026-09-06 07:00:00	2026-07-13 07:00:00	40	2026-05-19 11:02:03.343	2026-06-05 09:22:33.056	f	1000	0	0.25	[{"id": "1779188301419", "count": 40, "title": "Genel Test", "points": "0.20"}]	50	f	CUSTOM	\N	cmpgmoa5h007vhk9k9lg24vxz	STANDART
cmpcfzz8p00q7hkdzbyqstd86	KPSS MUHASEBE DENEME 3	Muhasebe Deneme 3	/uploads/1779183635446-sinav-6.-Bask-_MUHASEBE-4T-10-LU-ALAN-DENEMELERI--3.pdf	/uploads/1779183635491-cozum-6.-Bask-_MUHASEBE-4T-10-LU-ALAN-DENEMELERI----Z-M-3.pdf	2026-07-05 07:00:00	2026-09-06 07:00:00	2026-07-06 07:00:00	40	2026-05-19 09:40:35.497	2026-06-05 09:35:12.89	f	1000	0	0.25	[{"id": "1779183019026", "count": 40, "title": "Genel Test", "points": "0.20"}]	50	f	CUSTOM	\N	cmpfkcbpz0213hkzb7z4p2re7	STANDART
cmpcfmqag00bohkdzqj6m6c8w	KPSS MALİYE DENEME 3	Maliye Deneme 3	/uploads/1779183017318-sinav-5.-Bask-_MALI-YE-4T-10-LU-ALAN-DENEMELERI--3.pdf	/uploads/1779183017362-cozum-5.-Bask-_MALI-YE-4T-10-LU-ALAN-DENEMELERI----Z-M-3.pdf	2026-07-05 07:00:00	2026-09-06 07:00:00	2026-07-06 07:00:00	40	2026-05-19 09:30:17.368	2026-06-05 09:38:27.146	f	1000	0	0.25	[{"id": "1779182577384", "count": 40, "title": "Genel Test", "points": "0.20"}]	50	f	CUSTOM	\N	cmpfkcbpz0213hkzb7z4p2re7	STANDART
cmpceayuj0002hkdzv7kk1kr6	KPSS HUKUK DENEME 2	Hukuk Deneme 2	/uploads/1779180788601-sinav-5.-Bask-_HUKUK-4T-10-LU-ALAN-DENEMELERI--2.pdf	/uploads/1779180788957-cozum-5.-Bask-_HUKUK-4T-10-LU-ALAN-DENEMELERI----Z-M-2.pdf	2026-06-28 07:00:00	2026-09-06 07:00:00	2026-06-29 07:00:00	40	2026-05-19 08:53:08.972	2026-06-05 09:39:29.855	f	1000	0	0.25	[{"id": "1779180255653", "count": 40, "title": "Hukuk", "points": "0.20"}]	50	f	CUSTOM	\N	cmpfeyk3p01t7hkzbpf34p0yd	STANDART
cmp5jiu2e0019hkntf5ix2t9l	KPSS MUHASEBE DENEME 1	Muhasebe Deneme 1	/uploads/1778766290796-sinav-6.-Bask-_MUHASEBE-4T-10-LU-ALAN-DENEMELERI--1.pdf	/uploads/1778766290863-cozum-6.-Bask-_MUHASEBE-4T-10-LU-ALAN-DENEMELERI----Z-M-1.pdf	2026-06-21 07:00:00	2026-09-06 07:00:00	2026-06-22 07:00:00	40	2026-05-14 13:44:50.87	2026-06-05 09:41:31.25	f	1000	0	0.25	[{"id": "1778765829482", "count": 40, "title": "MUHASEBE", "points": "0.20"}]	50	f	CUSTOM	\N	cmpfbt7tb006rhkzbr1k26q0j	STANDART
cmpfbgd4j0002hkzbbn0o1dlo	KPSS GK-GY DENEME 1	GK GY Deneme 1	/uploads/1779357400334-sinav-3.-BASKI---1-SORU-KPSS-B-10-LU-DENEME.pdf	/uploads/1779357400421-cozum-3.-BASKI---1---Z-M-KPSS-B-10-LU-DENEME.pdf	2026-06-20 07:00:00	2026-09-06 07:00:00	2026-06-22 07:00:00	120	2026-05-21 09:56:40.436	2026-06-04 13:42:31.873	f	1000	0	0.25	[{"id": "1779354306342", "count": "60", "title": "Genel Yetenek", "points": "0.10"}, {"id": "1779354374863", "count": "60", "title": "Genel Kültür", "points": "0.10"}]	130	f	KPSS_P3	\N	cmpfbt7tb006rhkzbr1k26q0j	GY_GK
cmpcemfd9003khkdzydlfo0v9	KPSS MALİYE DENEME 2	Maliye Deneme 2	/uploads/1779181323523-sinav-5.-Bask-_MALI-YE-4T-10-LU-ALAN-DENEMELERI--2.pdf	/uploads/1779181323591-cozum-5.-Bask-_MALI-YE-4T-10-LU-ALAN-DENEMELERI----Z-M-2.pdf	2026-07-28 07:00:00	2026-09-06 07:00:00	2026-07-29 07:00:00	40	2026-05-19 09:02:03.597	2026-06-05 09:40:39.068	f	1000	0	0.25	[{"id": "1779181085220", "count": 40, "title": "Maliye", "points": "0.20"}]	50	f	CUSTOM	\N	cmpfeyk3p01t7hkzbpf34p0yd	STANDART
cmpch8fca00rehkdz8hbidxis	KPSS HUKUK DENEME 4	Hukuk Deneme 4	/uploads/1779185709151-sinav-5.-Bask-_HUKUK-4T-10-LU-ALAN-DENEMELERI--4.pdf	/uploads/1779185709220-cozum-5.-Bask-_HUKUK-4T-10-LU-ALAN-DENEMELERI----Z-M-4.pdf	2026-07-12 07:00:00	2026-09-06 07:00:00	2026-07-13 07:00:00	40	2026-05-19 10:15:09.226	2026-06-05 09:22:51.877	f	1000	0	0.25	[{"id": "1779185479919", "count": 40, "title": "Genel Test", "points": "0.20"}]	50	f	CUSTOM	\N	cmpgmoa5h007vhk9k9lg24vxz	STANDART
cmpfka7qt01xqhkzbwuyum22o	KPSS GK-GY DENEME 3	GK GY Deneme 3	/uploads/1779372229991-sinav-3.-BASKI---3-SORU-KPSS-B-10-LU-DENEME.pdf	/uploads/1779372230062-cozum-3.-BASKI---3---Z-M-KPSS-B-10-LU-DENEME.pdf	2026-07-04 07:00:00	2026-09-06 07:00:00	2026-07-06 07:00:00	120	2026-05-21 14:03:50.069	2026-06-05 09:35:30.891	f	1000	0	0.25	[{"id": "1779371525935", "count": "60", "title": "Genel Yetenek", "points": "0.10"}, {"id": "1779371587893", "count": "60", "title": "Genel Kültür", "points": "0.10"}]	130	f	KPSS_P3	\N	cmpfkcbpz0213hkzb7z4p2re7	STANDART
cmp45g62r00pshk447kwwuu5q	KPSS HUKUK DENEME 1	Hukuk 1. Deneme 	/uploads/1778682185344-sinav-5.-Bask-_HUKUK-4T-10-LU-ALAN-DENEMELERI--1.pdf	/uploads/1778682185652-cozum-5.-Bask-_HUKUK-4T-10-LU-ALAN-DENEMELERI----Z-M-1.pdf	2026-06-21 07:00:00	2026-09-06 07:00:00	2026-06-22 07:00:00	40	2026-05-13 14:23:05.667	2026-06-05 09:42:18.12	f	1000	0	0.25	[{"id": "1778681857812", "count": 40, "title": "HUKUK", "points": "0.20"}]	50	f	CUSTOM	\N	cmpfbt7tb006rhkzbr1k26q0j	STANDART
cmp46ome900s3hk44i4eqvhx8	KPSS İKTİSAT DENEME 1	İktisat 1. Deneme	/uploads/1778684259219-sinav-5.-Bask-_I-KTI-SAT-4T-10-LU-ALAN-DENEMELERI--1.pdf	/uploads/1778684259590-cozum-5.-Bask-_I-KTI-SAT-4T-10-LU-ALAN-DENEMELERI----Z-M-1.pdf	2026-06-21 07:00:00	2026-09-06 07:00:00	2026-06-22 07:00:00	40	2026-05-13 14:57:39.68	2026-06-05 08:46:13.451	f	1000	0	0.25	[{"id": "1778682186139", "count": 40, "title": "İKTİSAT", "points": "0.20"}]	50	f	CUSTOM	\N	cmpfbt7tb006rhkzbr1k26q0j	STANDART
cmpfexe0c01puhkzb3pkg2qkg	KPSS GK-GY DENEME 2	GK GY Deneme 2	/uploads/1779363233495-sinav-3.-BASKI---2-SORU-KPSS-B-10-LU-DENEME-.pdf	/uploads/1779363233566-cozum-3.-BASKI---2---Z-M-KPSS-B-10-LU-DENEME.pdf	2026-06-27 07:00:00	2026-09-06 07:00:00	2026-06-29 07:00:00	120	2026-05-21 11:33:53.58	2026-06-04 13:49:49.648	f	1000	0	0.25	[{"id": "1779362792571", "count": "60", "title": "Genel Yetenek", "points": "0.10"}, {"id": "1779362861475", "count": "60", "title": "Genel Kültür", "points": "0.10"}]	130	f	KPSS_P3	\N	cmpfeyk3p01t7hkzbpf34p0yd	STANDART
cmpgmklqk0002hk9karfvcygv	KPSS GK-GY DENEME 4	GK GY Deneme 4	/uploads/1779436540042-sinav-3.-BASKI---4-SORU-KPSS-B-10-LU-DENEME.pdf	/uploads/1779436540096-cozum-3.-BASKI---4---Z-M-KPSS-B-10-LU-DENEME.pdf	2026-07-11 07:00:00	2026-09-06 07:00:00	2026-07-13 07:00:00	120	2026-05-22 07:55:40.173	2026-06-04 13:58:45.184	f	1000	0	0.25	[{"id": "1779435844803", "count": "60", "title": "Genel Yetenek", "points": "0.10"}, {"id": "1779435932803", "count": "60", "title": "Genel Kültür", "points": "0.10"}]	130	f	KPSS_P3	\N	cmpgmoa5h007vhk9k9lg24vxz	STANDART
cmpcirzfp00tphkdz1ul5o9la	KPSS İKTİSAT DENEME 4	İktisat Deneme 4	/uploads/1779188301301-sinav-5.-Bask-_I-KTI-SAT-4T-10-LU-ALAN-DENEMELERI--4.pdf	/uploads/1779188301343-cozum-5.-Bask-_I-KTI-SAT-4T-10-LU-ALAN-DENEMELERI----Z-M-4.pdf	2026-07-12 07:00:00	2026-09-06 07:00:00	2026-07-13 07:00:00	40	2026-05-19 10:58:21.349	2026-06-05 09:04:23.05	f	1000	0	0.25	[{"id": "1779185710955", "count": 40, "title": "Genel Test", "points": "0.20"}]	50	f	CUSTOM	\N	cmpgmoa5h007vhk9k9lg24vxz	STANDART
cmpcf6a4t005yhkdz4769ze1s	KPSS HUKUK DENEME 3	Hukuk Deneme 3	/uploads/1779182249868-sinav-5.-Bask-_HUKUK-4T-10-LU-ALAN-DENEMELERI--3.pdf	/uploads/1779182249924-cozum-5.-Bask-_HUKUK-4T-10-LU-ALAN-DENEMELERI----Z-M-3.pdf	2026-07-05 07:00:00	2026-09-06 07:00:00	2026-07-06 07:00:00	40	2026-05-19 09:17:29.933	2026-06-04 14:42:42.138	f	1000	0	0.25	[{"id": "1779181828500", "count": 40, "title": "Hukuk", "points": "0.20"}]	50	f	CUSTOM	\N	cmpfkcbpz0213hkzb7z4p2re7	STANDART
cmpceulay004rhkdzau8ylxgo	KPSS MUHASEBE DENEME 2	Muhasebe Deneme 2	/uploads/1779181704462-sinav-6.-Bask-_MUHASEBE-4T-10-LU-ALAN-DENEMELERI--2.pdf	/uploads/1779181704532-cozum-6.-Bask-_MUHASEBE-4T-10-LU-ALAN-DENEMELERI----Z-M-2.pdf	2026-07-28 07:00:00	2026-09-06 07:00:00	2026-07-29 07:00:00	40	2026-05-19 09:08:24.538	2026-06-05 09:40:09.896	f	1000	0	0.25	[{"id": "1779181325234", "count": 40, "title": "Muhasebe", "points": "0.20"}]	50	f	CUSTOM	\N	cmpfeyk3p01t7hkzbpf34p0yd	STANDART
cmpwtb2xy006uhkwpk9nf103t	KPSS GK-GY DENEME 6	GK GY Deneme 6	/uploads/1780415311927-sinav-3.-BASKI---6-SORU-KPSS-B-10-LU-DENEME.pdf	/uploads/1780415312020-cozum-3.-BASKI---6---Z-M-KPSS-B-10-LU-DENEME.pdf	2026-07-25 07:00:00	2026-09-06 07:00:00	2026-07-27 07:00:00	120	2026-06-02 15:48:32.038	2026-06-04 14:05:42.782	f	1000	0	0.25	[{"id": "1780414652015", "count": "60", "title": "Genel Yetenek ", "points": "0.10"}, {"id": "1780414812925", "count": "60", "title": "Genel Kültür", "points": "0.10"}]	130	f	KPSS_P3	\N	cmpwugszd00g3hkwp90n25b9a	STANDART
cmpcmu9th010mhkdzuyws3446	KPSS HUKUK DENEME 5	Hukuk Deneme 5	/uploads/1779195126519-sinav-5.-Bask-_HUKUK-4T-10-LU-ALAN-DENEMELERI--5.pdf	/uploads/1779195126573-cozum-5.-Bask-_HUKUK-4T-10-LU-ALAN-DENEMELERI----Z-M-5.pdf	2026-07-19 07:00:00	2026-09-06 07:00:00	2026-07-20 07:00:00	40	2026-05-19 12:52:06.581	2026-06-04 14:47:40.247	f	1000	0	0.25	[{"id": "1779192968703", "count": 40, "title": "Genel Test", "points": "0.20"}]	50	f	CUSTOM	\N	cmpwsyaiv003fhkwpc4bvp7k2	STANDART
cmpcmzxsi012xhkdzrbj8fjy8	KPSS İKTİSAT DENEME 5	İktisat Deneme 5	/uploads/1779195390906-sinav-5.-Bask-_I-KTI-SAT-4T-10-LU-ALAN-DENEMELERI--5.pdf	/uploads/1779195390924-cozum-5.-Bask-_I-KTI-SAT-4T-10-LU-ALAN-DENEMELERI----Z-M-5.pdf	2026-07-19 07:00:00	2026-09-06 07:00:00	2026-07-20 07:00:00	40	2026-05-19 12:56:30.93	2026-06-05 09:04:53.27	f	1000	0	0.25	[{"id": "1779195126797", "count": 40, "title": "Genel Test", "points": "0.20"}]	50	f	CUSTOM	\N	cmpwsyaiv003fhkwpc4bvp7k2	STANDART
cmpwti7yo00a9hkwpb12fvmcd	KPSS HUKUK DENEME 6	Hukuk Deneme 6	/uploads/1780415645082-sinav-5.-Bask-_HUKUK-4T-10-LU-ALAN-DENEMELERI--6.pdf	/uploads/1780415645130-cozum-5.-Bask-_HUKUK-4T-10-LU-ALAN-DENEMELERI----Z-M-6.pdf	2026-07-26 07:00:00	2026-09-06 07:00:00	2026-07-27 07:00:00	40	2026-06-02 15:54:05.137	2026-06-05 09:17:38.972	f	1000	0	0.25	[{"id": "1780415312462", "count": 40, "title": "Genel Test", "points": "0.20"}]	50	f	CUSTOM	\N	cmpwugszd00g3hkwp90n25b9a	STANDART
cmpwswxce0002hkwpttlr7zwx	KPSS GK-GY DENEME 5	GK GY Deneme 5	/uploads/1780414651496-sinav-3.-BASKI---5-SORU-KPSS-B-10-LU-DENEME.pdf	/uploads/1780414651559-cozum-3.-BASKI---5---Z-M-KPSS-B-10-LU-DENEME.pdf	2026-07-18 07:00:00	2026-09-06 07:00:00	2026-07-20 07:00:00	120	2026-06-02 15:37:31.598	2026-06-04 14:01:48.9	f	1000	0	0.25	[{"id": "1780414065839", "count": "60", "title": "Genel Yetenek", "points": "0.10"}, {"id": "1780414125908", "count": "60", "title": "Genel Kültür", "points": "0.10"}]	130	f	KPSS_P3	\N	cmpwsyaiv003fhkwpc4bvp7k2	STANDART
cmpcnbiae017jhkdzjao1489e	KPSS MUHASEBE DENEME 5	Muhasebe Deneme 5	/uploads/1779195930642-sinav-6.-Bask-_MUHASEBE-4T-10-LU-ALAN-DENEMELERI--5.pdf	/uploads/1779195930704-cozum-6.-Bask-_MUHASEBE-4T-10-LU-ALAN-DENEMELERI----Z-M-5.pdf	2026-07-19 07:00:00	2026-09-06 07:00:00	2026-07-20 07:00:00	40	2026-05-19 13:05:30.71	2026-06-05 09:18:17.873	f	1000	0	0.25	[{"id": "1779195600981", "count": 40, "title": "Genel Test", "points": "0.20"}]	50	f	CUSTOM	\N	cmpwsyaiv003fhkwpc4bvp7k2	ALAN
cmpcn4fom0158hkdzn2o5idv8	KPSS MALİYE DENEME 5	Maliye Deneme 5	/uploads/1779195600658-sinav-5.-Bask-_MALI-YE-4T-10-LU-ALAN-DENEMELERI--5.pdf	/uploads/1779195600735-cozum-5.-Bask-_MALI-YE-4T-10-LU-ALAN-DENEMELERI----Z-M-5.pdf	2026-07-19 07:00:00	2026-09-06 07:00:00	2026-07-20 07:00:00	40	2026-05-19 13:00:00.743	2026-06-05 09:19:41.479	f	1000	0	0.25	[{"id": "1779195391161", "count": 40, "title": "Genel Test", "points": "0.20"}]	50	f	CUSTOM	\N	cmpwsyaiv003fhkwpc4bvp7k2	STANDART
cmpxsd15o001bhke6zja5eqfk	KPSS İKTİSAT DENEME 7	İktisat Deneme 7	/uploads/1780474189510-sinav-5.-Bask-_I-KTI-SAT-4T-10-LU-ALAN-DENEMELERI--7.pdf	/uploads/1780474189586-cozum-5.-Bask-_I-KTI-SAT-4T-10-LU-ALAN-DENEMELERI----Z-M-7.pdf	2026-08-02 07:00:00	2026-09-06 07:00:00	2026-08-03 07:00:00	40	2026-06-03 08:09:49.596	2026-06-05 09:06:16.757	f	1000	100	0.25	[{"id": "1780472588930", "count": 40, "title": "Genel Test", "points": "0.20"}]	50	f	CUSTOM	\N	cmpxtftzd004uhke633drq8gy	STANDART
cmpxsu9qy003phke65kkykwv8	KPSS MUHASEBE DENEME 7	Muhasebe Deneme 7	/uploads/1780474993806-sinav-6.-Bask-_MUHASEBE-4T-10-LU-ALAN-DENEMELERI--7.pdf	/uploads/1780474993873-cozum-6.-Bask-_MUHASEBE-4T-10-LU-ALAN-DENEMELERI----Z-M-7.pdf	2026-08-02 07:00:00	2026-09-06 07:00:00	2026-06-03 07:00:00	40	2026-06-03 08:23:13.882	2026-06-05 09:16:03.492	f	1000	0	0.25	[{"id": "1780474397915", "count": 40, "title": "Genel Test", "points": "0.20"}]	50	f	CUSTOM	\N	cmpxtftzd004uhke633drq8gy	STANDART
cmpxu82qi008chke6zpw3f0ll	KPSS HUKUK DENEME 8	Hukuk Deneme 8	/uploads/1780477317525-sinav-5.-Bask-_HUKUK-4T-10-LU-ALAN-DENEMELERI--8.pdf	/uploads/1780477317588-cozum-5.-Bask-_HUKUK-4T-10-LU-ALAN-DENEMELERI----Z-M-8.pdf	2026-08-09 07:00:00	2026-09-06 07:00:00	2026-08-10 07:00:00	40	2026-06-03 09:01:57.594	2026-06-05 09:15:07.062	f	1000	0	0.25	[{"id": "1780476815941", "count": 40, "title": "Genel Test", "points": "0.20"}]	50	f	CUSTOM	\N	cmpxvd3xa00d2hke6zcymlfd8	STANDART
cmpwufjvi00eyhkwp5jo44dff	KPSS MUHASEBE DENEME 6	Muhasebe Deneme 6	/uploads/1780417200164-sinav-6.-Bask-_MUHASEBE-4T-10-LU-ALAN-DENEMELERI--6.pdf	/uploads/1780417200216-cozum-6.-Bask-_MUHASEBE-4T-10-LU-ALAN-DENEMELERI----Z-M-6.pdf	2026-07-26 07:00:00	2026-09-06 07:00:00	2026-07-27 07:00:00	40	2026-06-02 16:20:00.222	2026-06-05 09:17:08.375	f	1000	0	0.25	[{"id": "1780416844384", "count": 40, "title": "Genel Test", "points": "0.20"}]	50	f	CUSTOM	\N	cmpwugszd00g3hkwp90n25b9a	STANDART
cmpwu7wz500cnhkwpbjuja1wf	KPSS MALİYE DENEME 6	Maliye Deneme 6	/uploads/1780416843898-sinav-5.-Bask-_MALI-YE-4T-10-LU-ALAN-DENEMELERI--6.pdf	/uploads/1780416843947-cozum-5.-Bask-_MALI-YE-4T-10-LU-ALAN-DENEMELERI----Z-M-6.pdf	2026-07-26 07:00:00	2026-09-06 07:00:00	2026-07-27 07:00:00	40	2026-06-02 16:14:03.953	2026-06-05 09:17:28.691	f	1000	0	0.25	[{"id": "1780415903582", "count": 40, "title": "Genel Test", "points": "0.20"}]	50	f	CUSTOM	\N	cmpwugszd00g3hkwp90n25b9a	STANDART
cmpxtxasu004xhke6zparbgm5	KPSS GK-GY DENEME 8	GK GY Deneme 8	/uploads/1780476814777-sinav-3.-BASKI---8-SORU-KPSS-B-10-LU-DENEME.pdf	/uploads/1780476814823-cozum-3.-BASKI---8---Z-M-KPSS-B-10-LU-DENEME.pdf	2026-08-08 07:00:00	2026-09-06 07:00:00	2026-08-10 07:00:00	120	2026-06-03 08:53:34.83	2026-06-05 09:15:21.613	f	1000	0	0.25	[{"id": "1780474994774", "count": "60", "title": "Genel Kültür", "points": "0.10"}, {"id": "1780476289423", "count": "60", "title": "Genel Yetenek", "points": "0.10"}]	130	f	KPSS_P3	\N	cmpxvd3xa00d2hke6zcymlfd8	STANDART
cmpwv00t600g6hkwpdimacnkh	KPSS GK-GY DENEME 7	GK GY Deneme 7	/uploads/1780418155145-sinav-3.-BASKI---7-SORU-KPSS-B-10-LU-DENEME.pdf	/uploads/1780418155277-cozum-3.-BASKI---7---Z-M-KPSS-B-10-LU-DENEME.pdf	2026-08-01 07:00:00	2026-09-06 07:00:00	2026-08-03 07:00:00	120	2026-06-02 16:35:55.29	2026-06-04 14:10:07.498	f	1000	0	0.25	[{"id": "1780417200656", "count": "60", "title": "Genel Yetenek ", "points": "0.10"}, {"id": "1780417304848", "count": "60", "title": "Genel Kültür", "points": "0.10"}]	130	f	KPSS_P3	\N	cmpxtftzd004uhke633drq8gy	STANDART
cmpxshh83002ihke6w6k0fvdx	KPSS MALİYE DENEME 7	Maliye Deneme 7	/uploads/1780474397017-sinav-5.-Bask-_I-KTI-SAT-4T-10-LU-ALAN-DENEMELERI--7.pdf	/uploads/1780474397034-cozum-5.-Bask-_I-KTI-SAT-4T-10-LU-ALAN-DENEMELERI----Z-M-7.pdf	2026-08-02 07:00:00	2026-09-06 07:00:00	2026-08-03 07:00:00	40	2026-06-03 08:13:17.043	2026-06-05 09:16:22.805	f	1000	0	0.25	[{"id": "1780474190476", "count": 40, "title": "Genel Test", "points": "0.20"}]	50	f	CUSTOM	\N	cmpxtftzd004uhke633drq8gy	STANDART
cmpxrepeb0004hke67fbajpe7	KPSS HUKUK DENEME 7	Hukuk Deneme 7	/uploads/1780472587974-sinav-5.-Bask-_HUKUK-4T-10-LU-ALAN-DENEMELERI--7.pdf	/uploads/1780472588042-cozum-5.-Bask-_HUKUK-4T-10-LU-ALAN-DENEMELERI----Z-M-7.pdf	2026-08-02 07:00:00	2026-09-06 07:00:00	2026-08-03 07:00:00	40	2026-06-03 07:43:08.051	2026-06-05 09:16:44.696	f	1000	0	0.25	[{"id": "1780472351312", "count": 40, "title": "Genel Test", "points": "0.20"}]	50	f	CUSTOM	\N	cmpxtftzd004uhke633drq8gy	STANDART
cmpwtnr2b00bghkwp97a1ohni	KPSS İKTİSAT DENEME 6	İktisat Deneme 6	/uploads/1780415903153-sinav-5.-Bask-_I-KTI-SAT-4T-10-LU-ALAN-DENEMELERI--6.pdf	/uploads/1780415903165-cozum-5.-Bask-_I-KTI-SAT-4T-10-LU-ALAN-DENEMELERI----Z-M-6.pdf	2026-07-26 07:00:00	2026-09-06 07:00:00	2026-07-27 07:00:00	40	2026-06-02 15:58:23.171	2026-06-05 09:05:22.787	f	1000	0	0.25	[{"id": "1780415645543", "count": 40, "title": "Genel Test", "points": "0.20"}]	50	f	CUSTOM	\N	cmpwugszd00g3hkwp90n25b9a	STANDART
cmpxui50s009jhke63ury65bc	KPSS İKTİSAT DENEME 8	İktisat Deneme 8	/uploads/1780477787059-sinav-5.-Bask-_I-KTI-SAT-4T-10-LU-ALAN-DENEMELERI--8.pdf	/uploads/1780477787109-cozum-5.-Bask-_I-KTI-SAT-4T-10-LU-ALAN-DENEMELERI----Z-M-8.pdf	2026-08-09 07:00:00	2026-09-06 07:00:00	2026-08-10 07:00:00	40	2026-06-03 09:09:47.117	2026-06-05 09:15:38.19	f	1000	0	0.25	[{"id": "1780477318548", "count": 40, "title": "Genel Test", "points": "0.20"}]	50	f	CUSTOM	\N	cmpxvd3xa00d2hke6zcymlfd8	STANDART
cmpxw7hz500pzhke6tmzzhqma	KPSS İKTİSAT DENEME 10	İktisat Deneme 10	/uploads/1780480649905-sinav-5.-Bask-_I-KTI-SAT-4T-10-LU-ALAN-DENEMELERI--10.pdf	/uploads/1780480649913-cozum-5.-Bask-_I-KTI-SAT-4T-10-LU-ALAN-DENEMELERI----Z-M-10.pdf	2026-08-23 07:00:00	2026-09-06 07:00:00	2026-08-24 07:00:00	40	2026-06-03 09:57:29.921	2026-06-05 09:11:07.298	f	1000	0	0.25	[{"id": "1780480580813", "count": 40, "title": "Genel Test", "points": "0.20"}]	50	f	CUSTOM	\N	cmpxwbn3w00tihke6wrroq7vi	STANDART
cmpxw5zub00oshke69lnxt9hl	KPSS HUKUK DENEME 10	Hukuk Deneme 10	/uploads/1780480579750-sinav-5.-Bask-_HUKUK-4T-10-LU-ALAN-DENEMELERI--10.pdf	/uploads/1780480579757-cozum-5.-Bask-_HUKUK-4T-10-LU-ALAN-DENEMELERI----Z-M-10.pdf	2026-08-23 07:00:00	2026-09-06 07:00:00	2026-08-24 07:00:00	40	2026-06-03 09:56:19.763	2026-06-05 09:11:25.44	f	1000	0	0.25	[{"id": "1780480507592", "count": 40, "title": "Genel Test", "points": "0.20"}]	50	f	CUSTOM	\N	cmpxwbn3w00tihke6wrroq7vi	STANDART
cmpxw01dc00k5hke61wbi7nqp	KPSS MUHASEBE DENEME 9	Muhasebe Deneme 9	/uploads/1780480301790-sinav-6.-Bask-_MUHASEBE-4T-10-LU-ALAN-DENEMELERI--9.pdf	/uploads/1780480301801-cozum-6.-Bask-_MUHASEBE-4T-10-LU-ALAN-DENEMELERI----Z-M-9.pdf	2026-08-16 07:00:00	2026-09-06 07:00:00	2026-08-17 07:00:00	40	2026-06-03 09:51:41.809	2026-06-05 09:12:09.73	f	1000	0	0.25	[{"id": "1780480214429", "count": 40, "title": "Genel Test", "points": "0.20"}]	50	f	CUSTOM	\N	cmpxw13md00lahke69zt65l7w	STANDART
cmpxvwgb700hrhke60gvfnxza	KPSS İKTİSAT DENEME 9	İktisat Deneme 9	/uploads/1780480134532-sinav-5.-Bask-_I-KTI-SAT-4T-10-LU-ALAN-DENEMELERI--9.pdf	/uploads/1780480134541-cozum-5.-Bask-_I-KTI-SAT-4T-10-LU-ALAN-DENEMELERI----Z-M-9.pdf	2026-08-16 07:00:00	2026-09-06 07:00:00	2026-08-17 07:00:00	40	2026-06-03 09:48:54.548	2026-06-05 09:09:54.43	f	1000	0	0.25	[{"id": "1780480054845", "count": 40, "title": "Genel Test", "points": "0.20"}]	50	f	CUSTOM	\N	cmpxw13md00lahke69zt65l7w	STANDART
cmpxvy55s00iyhke6ha2zs62d	KPSS MALİYE DENEME 9	Maliye Deneme 9	/uploads/1780480213390-sinav-5.-Bask-_MALI-YE-4T-10-LU-ALAN-DENEMELERI--9.pdf	/uploads/1780480213402-cozum-5.-Bask-_MALI-YE-4T-10-LU-ALAN-DENEMELERI----Z-M-9.pdf	2026-08-16 07:00:00	2026-09-06 07:00:00	2026-08-17 07:00:00	40	2026-06-03 09:50:13.408	2026-06-05 09:12:27.131	f	1000	0	0.25	[{"id": "1780480135532", "count": 40, "title": "Genel Test", "points": "0.20"}]	50	f	CUSTOM	\N	cmpxw13md00lahke69zt65l7w	STANDART
cmpxvii4a00d5hke622cduye0	KPSS GK-GY DENEME 9	GK GY Deneme 9	/uploads/1780479483620-sinav-3.-BASKI---9-SORU-KPSS-B-10-LU-DENEME.pdf	/uploads/1780479483697-cozum-3.-BASKI---9---Z-M-KPSS-B-10-LU-DENEME.pdf	2026-08-15 07:00:00	2026-09-06 07:00:00	2026-08-17 07:00:00	120	2026-06-03 09:38:03.706	2026-06-05 09:13:21.592	f	1000	0	0.25	[{"id": "1780479179132", "count": "60", "title": "Genel Yetenek", "points": "0.10"}, {"id": "1780479410361", "count": "60", "title": "Genel Kültür", "points": "0.10"}]	130	f	KPSS_P3	\N	cmpxw13md00lahke69zt65l7w	STANDART
cmpxvbycp00bxhke63m7149iv	KPSS MUHASEBE DENEME 8	Muhasebe Deneme 8	/uploads/1780479178076-sinav-6.-Bask-_MUHASEBE-4T-10-LU-ALAN-DENEMELERI--8.pdf	/uploads/1780479178146-cozum-6.-Bask-_MUHASEBE-4T-10-LU-ALAN-DENEMELERI----Z-M-8.pdf	2026-08-09 07:00:00	2026-09-06 07:00:00	2026-08-10 07:00:00	40	2026-06-03 09:32:58.153	2026-06-05 09:14:10.454	f	1000	0	0.25	[{"id": "1780478003045", "count": 40, "title": "Genel Test", "points": "0.20"}]	50	f	CUSTOM	\N	cmpxvd3xa00d2hke6zcymlfd8	STANDART
cmpxw9h0j00r6hke6jgtdhnth	KPSS MALİYE DENEME 10	Maliye Deneme 10	/uploads/1780480741963-sinav-5.-Bask-_MALI-YE-4T-10-LU-ALAN-DENEMELERI--10.pdf	/uploads/1780480741979-cozum-5.-Bask-_MALI-YE-4T-10-LU-ALAN-DENEMELERI----Z-M-10.pdf	2026-08-23 07:00:00	2026-09-06 07:00:00	2026-08-24 07:00:00	40	2026-06-03 09:59:01.987	2026-06-05 09:10:42.204	f	1000	0	0.25	[{"id": "1780480650940", "count": 40, "title": "Genel Test", "points": "0.20"}]	50	f	CUSTOM	\N	cmpxwbn3w00tihke6wrroq7vi	STANDART
cmpxvuq1d00gkhke6xmwxml94	KPSS HUKUK DENEME 9	Hukuk Denem 9	/uploads/1780480053766-sinav-5.-Bask-_HUKUK-4T-10-LU-ALAN-DENEMELERI--9.pdf	/uploads/1780480053834-cozum-5.-Bask-_HUKUK-4T-10-LU-ALAN-DENEMELERI----Z-M-9.pdf	2026-08-16 07:00:00	2026-09-06 07:00:00	2026-08-17 07:00:00	40	2026-06-03 09:47:33.841	2026-06-05 09:12:59.862	f	1000	0	0.25	[{"id": "1780479484709", "count": 40, "title": "Genel Test", "points": "0.20"}]	50	f	CUSTOM	\N	cmpxw13md00lahke69zt65l7w	STANDART
cmpxw4fdb00ldhke6mjnc94ez	KPSS GK-GY DENEME 10	GK GY Deneme 10	/uploads/1780480506475-sinav-3.-BASKI---10-SORU-KPSS-B-10-LU-DENEME.pdf	/uploads/1780480506569-cozum-3.-BASKI---10---Z-M-KPSS-B-10-LU-DENEME.pdf	2026-08-22 07:00:00	2026-09-06 07:00:00	2026-08-24 07:00:00	120	2026-06-03 09:55:06.575	2026-06-05 09:11:49.032	f	1000	0	0.25	[{"id": "1780480302873", "count": "60", "title": "Genel Yetenek ", "points": "0.10"}, {"id": "1780480415321", "count": "60", "title": "Genel Kültür", "points": "0.10"}]	130	f	KPSS_P3	\N	cmpxwbn3w00tihke6wrroq7vi	STANDART
cmpxumqvw00aqhke6ocrgteiz	KPSS MALİYE DENEME 8	Maliye Deneme 8	/uploads/1780478002054-sinav-5.-Bask-_I-KTI-SAT-4T-10-LU-ALAN-DENEMELERI--8.pdf	/uploads/1780478002069-cozum-5.-Bask-_I-KTI-SAT-4T-10-LU-ALAN-DENEMELERI----Z-M-8.pdf	2026-08-09 07:00:00	2026-09-06 07:00:00	2026-08-10 07:00:00	40	2026-06-03 09:13:22.076	2026-06-05 09:14:39.24	f	1000	0	0.25	[{"id": "1780477788066", "count": 40, "title": "Genel Test", "points": "0.20"}]	50	f	CUSTOM	\N	cmpxvd3xa00d2hke6zcymlfd8	STANDART
cmpxwaxx600sdhke69schfi8y	KPSS MUHASEBE DENEME 10	Muhasebe Deneme 10	/uploads/1780480810492-sinav-6.-Bask-_MUHASEBE-4T-10-LU-ALAN-DENEMELERI--10.pdf	/uploads/1780480810548-cozum-6.-Bask-_MUHASEBE-4T-10-LU-ALAN-DENEMELERI----Z-M-10.pdf	2026-08-23 07:00:00	2026-09-06 07:00:00	2026-08-24 07:00:00	40	2026-06-03 10:00:10.554	2026-06-05 09:10:56.034	f	1000	0	0.25	[{"id": "1780480743000", "count": 40, "title": "Genel Test", "points": "0.20"}]	50	f	CUSTOM	\N	cmpxwbn3w00tihke6wrroq7vi	STANDART
\.


--
-- Data for Name: ExamPackage; Type: TABLE DATA; Schema: public; Owner: sinavsistemi_admin
--

COPY public."ExamPackage" (id, title, description, "isActive", "isSequential", "institutionId", "createdAt", "updatedAt", "showResultsTime") FROM stdin;
cmpxw13md00lahke69zt65l7w	KPSS DENEME 9	p48	t	f	\N	2026-06-03 09:52:31.381	2026-06-03 15:12:20.262	\N
cmpxvd3xa00d2hke6zcymlfd8	KPSS DENEME 8	P48	t	f	\N	2026-06-03 09:33:52.029	2026-06-03 15:12:26.342	\N
cmpxtftzd004uhke633drq8gy	KPSS DENEME 7	P48	t	f	\N	2026-06-03 08:39:59.88	2026-06-03 15:12:32.448	\N
cmpwugszd00g3hkwp90n25b9a	KPSS DENEME 6	P48	t	f	\N	2026-06-02 16:20:58.681	2026-06-03 15:12:38.178	\N
cmpwsyaiv003fhkwpc4bvp7k2	KPSS DENEME 5	P 48	t	f	\N	2026-06-02 15:38:35.335	2026-06-03 15:12:43.979	\N
cmpgmoa5h007vhk9k9lg24vxz	KPSS DENEME 4	P48	t	f	\N	2026-05-22 07:58:31.78	2026-06-03 15:12:49.892	\N
cmpfkcbpz0213hkzb7z4p2re7	KPSS DENEME 3	P48	t	f	\N	2026-05-21 14:05:28.534	2026-06-03 15:12:56.264	\N
cmpfeyk3p01t7hkzbpf34p0yd	KPSS DENEME 2	P48	t	f	\N	2026-05-21 11:34:48.132	2026-06-03 15:13:03.118	\N
cmpfbt7tb006rhkzbr1k26q0j	KPSS DENEME 1	P48	t	f	\N	2026-05-21 10:06:40.079	2026-06-03 15:13:09.896	\N
cmpxwbn3w00tihke6wrroq7vi	KPSS DENEME 10	P48	t	f	\N	2026-06-03 10:00:43.196	2026-06-04 13:09:29.554	\N
\.


--
-- Data for Name: ExamResult; Type: TABLE DATA; Schema: public; Owner: sinavsistemi_admin
--

COPY public."ExamResult" (id, "examId", "userId", score, "correctCount", "wrongCount", "emptyCount", "isFinished", "createdAt", "updatedAt", drawings) FROM stdin;
cmp8awh6l00mdhk5duk0hpxup	cmp5jiu2e0019hkntf5ix2t9l	cmor1ahhf0015hkemtlp0dxba	0.1000000000000002	8	30	2	t	2026-05-16 12:06:49.341	2026-05-16 12:07:42.373	\N
cmpfcqws200xjhkzbxd72s023	cmp5jiu2e0019hkntf5ix2t9l	cmpfcq6c000xhhkzbdz8k0oq1	0.6499999999999997	10	27	3	t	2026-05-21 10:32:52.082	2026-05-21 10:33:30.621	\N
cmpfcrvyl00znhkzbpaxyyzjd	cmpfbgd4j0002hkzbbn0o1dlo	cmpfcq6c000xhhkzbdz8k0oq1	22.267	20	88	12	t	2026-05-21 10:33:37.678	2026-05-21 10:36:11.01	\N
cmpfcw40h015phkzbh0mvsm8u	cmp46ome900s3hk44i4eqvhx8	cmpfcq6c000xhhkzbdz8k0oq1	0.2500000000000001	9	31	0	t	2026-05-21 10:36:54.737	2026-05-21 10:38:08.601	\N
cmpfcxqu9017zhkzb8biuvh51	cmp5j8xvh0002hkntbvhrqecu	cmpfcq6c000xhhkzbdz8k0oq1	0.4999999999999999	10	30	0	t	2026-05-21 10:38:10.938	2026-05-21 10:39:09.872	\N
cmpfcz2rw01a9hkzb9jckvy6i	cmp45g62r00pshk447kwwuu5q	cmpfcq6c000xhhkzbdz8k0oq1	1.249000902703301e-16	7	28	5	t	2026-05-21 10:39:13.1	2026-05-21 10:39:59.763	\N
\.


--
-- Data for Name: Group; Type: TABLE DATA; Schema: public; Owner: sinavsistemi_admin
--

COPY public."Group" (id, name, description, "createdAt", "updatedAt", "expireAt", "isActive", price, "institutionId", "parentId") FROM stdin;
cmp1dxlwe0003hkkng4uhejav	TYT 	TYT denemeleri	2026-05-11 15:57:17.725	2026-05-11 15:57:17.725	\N	t	2500	\N	\N
cmp1e35jr0005hkkne4to84pc	AYT	AYT denemeleri	2026-05-11 16:01:36.429	2026-05-11 16:01:36.429	\N	t	2500	\N	\N
cmp1e3hzb0006hkkn1vxam9a0	YKS 	YKS denemeleri	2026-05-11 16:01:52.583	2026-05-11 16:01:52.583	\N	t	4500	\N	\N
cmp44zr3i0017hk444oyr7dm3	Örgün Hafta Sonu Grubu	\N	2026-05-13 14:10:19.755	2026-05-13 14:10:19.755	\N	t	0	\N	\N
cmp455cds003mhk44nkrnvnb8	Örgün GK - GY	\N	2026-05-13 14:14:40.624	2026-05-13 14:14:40.624	\N	t	0	\N	\N
cmp455icp004fhk44v739jonr	Örgün 2. Grup	\N	2026-05-13 14:14:48.362	2026-05-13 14:14:48.362	\N	t	0	\N	\N
cmp455u3t0064hk44uozb26mm	Örgün 1. Grup	\N	2026-05-13 14:15:03.594	2026-05-13 14:15:03.594	\N	t	0	\N	\N
cmp4569ha008dhk4407omxehu	Online B Grubu	\N	2026-05-13 14:15:23.518	2026-05-13 14:15:23.518	\N	t	0	\N	\N
cmp456g99009ahk44c8zcwda8	Online 3. Grup A+B	\N	2026-05-13 14:15:32.301	2026-05-13 14:15:32.301	\N	t	0	\N	\N
cmp456msw009xhk440hz1q3mu	Online 3. Grup A	\N	2026-05-13 14:15:40.785	2026-05-13 14:15:40.785	\N	t	0	\N	\N
cmp456u0e00bahk44vqbidbz0	Online 2. Grup A+B	\N	2026-05-13 14:15:50.125	2026-05-13 14:15:50.125	\N	t	0	\N	\N
cmp456zoa00brhk44kp4noqp8	Online 2. Grup A	\N	2026-05-13 14:15:57.466	2026-05-13 14:15:57.466	\N	t	0	\N	\N
cmp4575k400d2hk44wb0llax7	Online 1. Grup A+B	\N	2026-05-13 14:16:05.092	2026-05-13 14:16:05.092	\N	t	0	\N	\N
cmp457wyq00idhk44pqhw6kmc	Online 1. Grup A	\N	2026-05-13 14:16:40.609	2026-05-13 14:16:40.609	\N	t	0	\N	\N
cmp4588ch00oyhk44scxlin0x	Deneme Grubu	\N	2026-05-13 14:16:55.362	2026-05-13 14:16:55.362	\N	t	0	\N	\N
cmp458sh600pbhk44o092kiio	Büyük Kamp 	\N	2026-05-13 14:17:21.45	2026-05-13 14:17:21.45	\N	t	0	\N	\N
cmplb4nw30000hkpzwrjyz8fl	Offline Grup	\N	2026-05-25 14:34:11.569	2026-05-25 14:34:11.569	\N	t	0	\N	\N
cmpy7fudv01a8hke6voabuhhl	TEK DERS	\N	2026-06-03 15:11:55.027	2026-06-03 15:11:55.027	\N	t	0	\N	\N
\.


--
-- Data for Name: Institution; Type: TABLE DATA; Schema: public; Owner: sinavsistemi_admin
--

COPY public."Institution" (id, name, subdomain, "isActive", "createdAt", "updatedAt") FROM stdin;
cmp1pjd6m0002hkxs0z39trcj	kognita	\N	f	2026-05-11 21:22:08.638	2026-05-11 21:33:27.196
cmp1py7ys0002hkpl7m0h92xb	Rüstem	\N	t	2026-05-11 21:33:41.716	2026-05-11 21:33:41.716
\.


--
-- Data for Name: PackageResult; Type: TABLE DATA; Schema: public; Owner: sinavsistemi_admin
--

COPY public."PackageResult" (id, "packageId", "userId", scores, "isComputed", "createdAt", "updatedAt") FROM stdin;
cmpfelav101l7hkzbdcjy9nvc	cmpfbt7tb006rhkzbr1k26q0j	cmor1ahhf0015hkemtlp0dxba	{"total": 0.5}	t	2026-05-21 11:24:29.63	2026-05-21 11:26:25.67
cmpfelaut01l5hkzb8ws77htf	cmpfbt7tb006rhkzbr1k26q0j	cmpfcq6c000xhhkzbdz8k0oq1	{"total": 5}	t	2026-05-21 11:24:29.622	2026-05-21 11:26:25.673
\.


--
-- Data for Name: QuestionKey; Type: TABLE DATA; Schema: public; Owner: sinavsistemi_admin
--

COPY public."QuestionKey" (id, "examId", "questionNumber", "correctOption", topic, "createdAt", "updatedAt", points, "videoUrl") FROM stdin;
cmq0pnawk011shk8dos8libzh	cmpwufjvi00eyhkwp5jo44dff	1	A	Genel Test	2026-06-05 09:17:08.468	2026-06-05 09:17:08.468	0.2	\N
cmq0pnawl011thk8dxsusk7m6	cmpwufjvi00eyhkwp5jo44dff	2	A	Genel Test	2026-06-05 09:17:08.468	2026-06-05 09:17:08.468	0.2	\N
cmq0pnawl011uhk8ddnbsjfwn	cmpwufjvi00eyhkwp5jo44dff	3	E	Genel Test	2026-06-05 09:17:08.468	2026-06-05 09:17:08.468	0.2	\N
cmq0pnawl011vhk8d9e803itk	cmpwufjvi00eyhkwp5jo44dff	4	B	Genel Test	2026-06-05 09:17:08.468	2026-06-05 09:17:08.468	0.2	\N
cmq0pnawl011whk8d95k9pz4n	cmpwufjvi00eyhkwp5jo44dff	5	A	Genel Test	2026-06-05 09:17:08.468	2026-06-05 09:17:08.468	0.2	\N
cmq0pnawl011xhk8d2pbaj8ry	cmpwufjvi00eyhkwp5jo44dff	6	A	Genel Test	2026-06-05 09:17:08.468	2026-06-05 09:17:08.468	0.2	\N
cmq0pnawl011yhk8d9wvvff2y	cmpwufjvi00eyhkwp5jo44dff	7	D	Genel Test	2026-06-05 09:17:08.468	2026-06-05 09:17:08.468	0.2	\N
cmq0pnawl011zhk8dys53xy38	cmpwufjvi00eyhkwp5jo44dff	8	E	Genel Test	2026-06-05 09:17:08.468	2026-06-05 09:17:08.468	0.2	\N
cmq0pnawl0120hk8dttntwwoo	cmpwufjvi00eyhkwp5jo44dff	9	E	Genel Test	2026-06-05 09:17:08.468	2026-06-05 09:17:08.468	0.2	\N
cmq0pnawl0121hk8dfgp0k7y3	cmpwufjvi00eyhkwp5jo44dff	10	A	Genel Test	2026-06-05 09:17:08.468	2026-06-05 09:17:08.468	0.2	\N
cmq0pnawl0122hk8dvnylddxg	cmpwufjvi00eyhkwp5jo44dff	11	D	Genel Test	2026-06-05 09:17:08.468	2026-06-05 09:17:08.468	0.2	\N
cmq0pnawl0123hk8dfhj468fg	cmpwufjvi00eyhkwp5jo44dff	12	D	Genel Test	2026-06-05 09:17:08.468	2026-06-05 09:17:08.468	0.2	\N
cmq0pnawl0124hk8dmfzidme1	cmpwufjvi00eyhkwp5jo44dff	13	D	Genel Test	2026-06-05 09:17:08.468	2026-06-05 09:17:08.468	0.2	\N
cmq0pnawl0125hk8d1tyxp0m6	cmpwufjvi00eyhkwp5jo44dff	14	A	Genel Test	2026-06-05 09:17:08.468	2026-06-05 09:17:08.468	0.2	\N
cmq0pnawl0126hk8d10k30p9x	cmpwufjvi00eyhkwp5jo44dff	15	B	Genel Test	2026-06-05 09:17:08.468	2026-06-05 09:17:08.468	0.2	\N
cmq0pnawl0127hk8dn9mhg5vt	cmpwufjvi00eyhkwp5jo44dff	16	E	Genel Test	2026-06-05 09:17:08.468	2026-06-05 09:17:08.468	0.2	\N
cmq0pnawl0128hk8d4zokp0pg	cmpwufjvi00eyhkwp5jo44dff	17	D	Genel Test	2026-06-05 09:17:08.468	2026-06-05 09:17:08.468	0.2	\N
cmq0pnawl0129hk8dll9d1sjn	cmpwufjvi00eyhkwp5jo44dff	18	D	Genel Test	2026-06-05 09:17:08.468	2026-06-05 09:17:08.468	0.2	\N
cmq0pnawl012ahk8dok1o92ma	cmpwufjvi00eyhkwp5jo44dff	19	E	Genel Test	2026-06-05 09:17:08.468	2026-06-05 09:17:08.468	0.2	\N
cmq0pnawl012bhk8dn5bargnh	cmpwufjvi00eyhkwp5jo44dff	20	E	Genel Test	2026-06-05 09:17:08.468	2026-06-05 09:17:08.468	0.2	\N
cmq0pnawl012chk8djuar7dti	cmpwufjvi00eyhkwp5jo44dff	21	E	Genel Test	2026-06-05 09:17:08.468	2026-06-05 09:17:08.468	0.2	\N
cmq0pnawl012dhk8dvr49fnji	cmpwufjvi00eyhkwp5jo44dff	22	D	Genel Test	2026-06-05 09:17:08.468	2026-06-05 09:17:08.468	0.2	\N
cmq0pnawl012ehk8deq32er02	cmpwufjvi00eyhkwp5jo44dff	23	A	Genel Test	2026-06-05 09:17:08.468	2026-06-05 09:17:08.468	0.2	\N
cmq0pnawl012fhk8d9e4fhh14	cmpwufjvi00eyhkwp5jo44dff	24	D	Genel Test	2026-06-05 09:17:08.468	2026-06-05 09:17:08.468	0.2	\N
cmq0pnawl012ghk8d1tuqvfv5	cmpwufjvi00eyhkwp5jo44dff	25	B	Genel Test	2026-06-05 09:17:08.468	2026-06-05 09:17:08.468	0.2	\N
cmq0pnawl012hhk8dhgk3m6dl	cmpwufjvi00eyhkwp5jo44dff	26	C	Genel Test	2026-06-05 09:17:08.468	2026-06-05 09:17:08.468	0.2	\N
cmq0pnawl012ihk8dsgrofarw	cmpwufjvi00eyhkwp5jo44dff	27	C	Genel Test	2026-06-05 09:17:08.468	2026-06-05 09:17:08.468	0.2	\N
cmq0pnawl012jhk8dzo84aojo	cmpwufjvi00eyhkwp5jo44dff	28	D	Genel Test	2026-06-05 09:17:08.468	2026-06-05 09:17:08.468	0.2	\N
cmq0pnawl012khk8dajkpbnsx	cmpwufjvi00eyhkwp5jo44dff	29	B	Genel Test	2026-06-05 09:17:08.468	2026-06-05 09:17:08.468	0.2	\N
cmq0pnawl012lhk8da5zqpc0q	cmpwufjvi00eyhkwp5jo44dff	30	E	Genel Test	2026-06-05 09:17:08.468	2026-06-05 09:17:08.468	0.2	\N
cmq0pnawl012mhk8dmn95voe7	cmpwufjvi00eyhkwp5jo44dff	31	C	Genel Test	2026-06-05 09:17:08.468	2026-06-05 09:17:08.468	0.2	\N
cmq0pnawl012nhk8dfo8q8j2e	cmpwufjvi00eyhkwp5jo44dff	32	B	Genel Test	2026-06-05 09:17:08.468	2026-06-05 09:17:08.468	0.2	\N
cmq0pnawm012ohk8dxlpcthde	cmpwufjvi00eyhkwp5jo44dff	33	B	Genel Test	2026-06-05 09:17:08.468	2026-06-05 09:17:08.468	0.2	\N
cmq0pnawm012phk8dkq114rib	cmpwufjvi00eyhkwp5jo44dff	34	D	Genel Test	2026-06-05 09:17:08.468	2026-06-05 09:17:08.468	0.2	\N
cmq0pnawm012qhk8d723c8psi	cmpwufjvi00eyhkwp5jo44dff	35	E	Genel Test	2026-06-05 09:17:08.468	2026-06-05 09:17:08.468	0.2	\N
cmq0pnawm012rhk8dztt6fh7j	cmpwufjvi00eyhkwp5jo44dff	36	C	Genel Test	2026-06-05 09:17:08.468	2026-06-05 09:17:08.468	0.2	\N
cmq0pnawm012shk8dzbh20fc1	cmpwufjvi00eyhkwp5jo44dff	37	B	Genel Test	2026-06-05 09:17:08.468	2026-06-05 09:17:08.468	0.2	\N
cmq0pgwhc00iwhk8dstrp2rmx	cmpxw01dc00k5hke61wbi7nqp	1	B	Genel Test	2026-06-05 09:12:09.84	2026-06-05 09:12:09.84	0.1	\N
cmq0qinqz01jkhk8du8hhpfrq	cmp5jiu2e0019hkntf5ix2t9l	1	E	MUHASEBE	2026-06-05 09:41:31.451	2026-06-05 09:41:31.451	0.2	\N
cmq0qinqz01jlhk8dkxb8qcm7	cmp5jiu2e0019hkntf5ix2t9l	2	E	MUHASEBE	2026-06-05 09:41:31.451	2026-06-05 09:41:31.451	0.2	\N
cmq0qinqz01jmhk8d5s5alur4	cmp5jiu2e0019hkntf5ix2t9l	3	A	MUHASEBE	2026-06-05 09:41:31.451	2026-06-05 09:41:31.451	0.2	\N
cmq0qinqz01jnhk8dbxtud2v6	cmp5jiu2e0019hkntf5ix2t9l	4	E	MUHASEBE	2026-06-05 09:41:31.451	2026-06-05 09:41:31.451	0.2	\N
cmq0qinqz01johk8deaqemew9	cmp5jiu2e0019hkntf5ix2t9l	5	C	MUHASEBE	2026-06-05 09:41:31.451	2026-06-05 09:41:31.451	0.2	\N
cmq0qinqz01jphk8do9i9d9ho	cmp5jiu2e0019hkntf5ix2t9l	6	B	MUHASEBE	2026-06-05 09:41:31.451	2026-06-05 09:41:31.451	0.2	\N
cmq0qinqz01jqhk8dr2msv055	cmp5jiu2e0019hkntf5ix2t9l	7	B	MUHASEBE	2026-06-05 09:41:31.451	2026-06-05 09:41:31.451	0.2	\N
cmq0qinqz01jrhk8duztmo72z	cmp5jiu2e0019hkntf5ix2t9l	8	D	MUHASEBE	2026-06-05 09:41:31.451	2026-06-05 09:41:31.451	0.2	\N
cmq0qinqz01jshk8dzbeos7a9	cmp5jiu2e0019hkntf5ix2t9l	9	D	MUHASEBE	2026-06-05 09:41:31.451	2026-06-05 09:41:31.451	0.2	\N
cmq0qinqz01jthk8d6k4ydnkd	cmp5jiu2e0019hkntf5ix2t9l	10	B	MUHASEBE	2026-06-05 09:41:31.451	2026-06-05 09:41:31.451	0.2	\N
cmq0qinqz01juhk8dmaqf4ngh	cmp5jiu2e0019hkntf5ix2t9l	11	A	MUHASEBE	2026-06-05 09:41:31.451	2026-06-05 09:41:31.451	0.2	\N
cmq0qinr001jvhk8dq2y03560	cmp5jiu2e0019hkntf5ix2t9l	12	B	MUHASEBE	2026-06-05 09:41:31.451	2026-06-05 09:41:31.451	0.2	\N
cmq0qinr001jwhk8dkr3qqmsq	cmp5jiu2e0019hkntf5ix2t9l	13	A	MUHASEBE	2026-06-05 09:41:31.451	2026-06-05 09:41:31.451	0.2	\N
cmq0qinr001jxhk8d0rox9zxc	cmp5jiu2e0019hkntf5ix2t9l	14	C	MUHASEBE	2026-06-05 09:41:31.451	2026-06-05 09:41:31.451	0.2	\N
cmq0pgwhc00ixhk8dutlzvtqj	cmpxw01dc00k5hke61wbi7nqp	2	C	Genel Test	2026-06-05 09:12:09.84	2026-06-05 09:12:09.84	0.1	\N
cmq0pgwhc00iyhk8dfc08nsjo	cmpxw01dc00k5hke61wbi7nqp	3	A	Genel Test	2026-06-05 09:12:09.84	2026-06-05 09:12:09.84	0.1	\N
cmq0pgwhc00izhk8dh5bvt22a	cmpxw01dc00k5hke61wbi7nqp	4	E	Genel Test	2026-06-05 09:12:09.84	2026-06-05 09:12:09.84	0.1	\N
cmq0pgwhc00j0hk8deb31mpjz	cmpxw01dc00k5hke61wbi7nqp	5	D	Genel Test	2026-06-05 09:12:09.84	2026-06-05 09:12:09.84	0.1	\N
cmq0pgwhc00j1hk8d6djnbhc5	cmpxw01dc00k5hke61wbi7nqp	6	C	Genel Test	2026-06-05 09:12:09.84	2026-06-05 09:12:09.84	0.1	\N
cmq0pgwhc00j2hk8dva3axwwm	cmpxw01dc00k5hke61wbi7nqp	7	D	Genel Test	2026-06-05 09:12:09.84	2026-06-05 09:12:09.84	0.1	\N
cmq0pgwhc00j3hk8d9o0fye53	cmpxw01dc00k5hke61wbi7nqp	8	B	Genel Test	2026-06-05 09:12:09.84	2026-06-05 09:12:09.84	0.1	\N
cmq0pgwhc00j4hk8d8twlgrk2	cmpxw01dc00k5hke61wbi7nqp	9	B	Genel Test	2026-06-05 09:12:09.84	2026-06-05 09:12:09.84	0.1	\N
cmq0pgwhc00j5hk8d3ihrbvhl	cmpxw01dc00k5hke61wbi7nqp	10	E	Genel Test	2026-06-05 09:12:09.84	2026-06-05 09:12:09.84	0.1	\N
cmq0pgwhc00j6hk8dqho17ppa	cmpxw01dc00k5hke61wbi7nqp	11	A	Genel Test	2026-06-05 09:12:09.84	2026-06-05 09:12:09.84	0.1	\N
cmq0pgwhc00j7hk8dep1l62lh	cmpxw01dc00k5hke61wbi7nqp	12	B	Genel Test	2026-06-05 09:12:09.84	2026-06-05 09:12:09.84	0.1	\N
cmq0pgwhc00j8hk8ddcf9hq7v	cmpxw01dc00k5hke61wbi7nqp	13	C	Genel Test	2026-06-05 09:12:09.84	2026-06-05 09:12:09.84	0.1	\N
cmq0pgwhc00j9hk8dwcm4xv3r	cmpxw01dc00k5hke61wbi7nqp	14	C	Genel Test	2026-06-05 09:12:09.84	2026-06-05 09:12:09.84	0.1	\N
cmq0pgwhc00jahk8dmv54ea0y	cmpxw01dc00k5hke61wbi7nqp	15	B	Genel Test	2026-06-05 09:12:09.84	2026-06-05 09:12:09.84	0.1	\N
cmq0pgwhc00jbhk8dr8x55si5	cmpxw01dc00k5hke61wbi7nqp	16	C	Genel Test	2026-06-05 09:12:09.84	2026-06-05 09:12:09.84	0.1	\N
cmq0pgwhc00jchk8d2fw5lwzu	cmpxw01dc00k5hke61wbi7nqp	17	E	Genel Test	2026-06-05 09:12:09.84	2026-06-05 09:12:09.84	0.1	\N
cmq0pgwhc00jdhk8d03aewbl3	cmpxw01dc00k5hke61wbi7nqp	18	A	Genel Test	2026-06-05 09:12:09.84	2026-06-05 09:12:09.84	0.1	\N
cmq0pgwhc00jehk8dlvitjzx0	cmpxw01dc00k5hke61wbi7nqp	19	B	Genel Test	2026-06-05 09:12:09.84	2026-06-05 09:12:09.84	0.1	\N
cmq0pgwhc00jfhk8dn62cjzny	cmpxw01dc00k5hke61wbi7nqp	20	E	Genel Test	2026-06-05 09:12:09.84	2026-06-05 09:12:09.84	0.1	\N
cmq0pgwhc00jghk8dsbr234pm	cmpxw01dc00k5hke61wbi7nqp	21	D	Genel Test	2026-06-05 09:12:09.84	2026-06-05 09:12:09.84	0.1	\N
cmq0pgwhc00jhhk8d6xpn5g7r	cmpxw01dc00k5hke61wbi7nqp	22	A	Genel Test	2026-06-05 09:12:09.84	2026-06-05 09:12:09.84	0.1	\N
cmq0pgwhc00jihk8dv62xv8n2	cmpxw01dc00k5hke61wbi7nqp	23	A	Genel Test	2026-06-05 09:12:09.84	2026-06-05 09:12:09.84	0.1	\N
cmq0pgwhc00jjhk8d3c5sdkkq	cmpxw01dc00k5hke61wbi7nqp	24	C	Genel Test	2026-06-05 09:12:09.84	2026-06-05 09:12:09.84	0.1	\N
cmq0pgwhc00jkhk8dwuuw2sry	cmpxw01dc00k5hke61wbi7nqp	25	D	Genel Test	2026-06-05 09:12:09.84	2026-06-05 09:12:09.84	0.1	\N
cmq0pgwhc00jlhk8df5x1r907	cmpxw01dc00k5hke61wbi7nqp	26	D	Genel Test	2026-06-05 09:12:09.84	2026-06-05 09:12:09.84	0.1	\N
cmq0pgwhc00jmhk8d0jyelwno	cmpxw01dc00k5hke61wbi7nqp	27	B	Genel Test	2026-06-05 09:12:09.84	2026-06-05 09:12:09.84	0.1	\N
cmq0pgwhd00jnhk8dst6ycxd9	cmpxw01dc00k5hke61wbi7nqp	28	D	Genel Test	2026-06-05 09:12:09.84	2026-06-05 09:12:09.84	0.1	\N
cmq0pgwhd00johk8drk3emvhw	cmpxw01dc00k5hke61wbi7nqp	29	A	Genel Test	2026-06-05 09:12:09.84	2026-06-05 09:12:09.84	0.1	\N
cmq0pgwhd00jphk8dbdwp6u28	cmpxw01dc00k5hke61wbi7nqp	30	D	Genel Test	2026-06-05 09:12:09.84	2026-06-05 09:12:09.84	0.1	\N
cmq0pgwhd00jqhk8dcyqbtd3v	cmpxw01dc00k5hke61wbi7nqp	31	A	Genel Test	2026-06-05 09:12:09.84	2026-06-05 09:12:09.84	0.1	\N
cmpzkik4q00gohk8cn4z0lfnq	cmpwtb2xy006uhkwpk9nf103t	1	D	Genel Yetenek 	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4q00gphk8cwfwujp4i	cmpwtb2xy006uhkwpk9nf103t	2	D	Genel Yetenek 	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4q00gqhk8cm7abis4q	cmpwtb2xy006uhkwpk9nf103t	3	B	Genel Yetenek 	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4q00grhk8cobozg73c	cmpwtb2xy006uhkwpk9nf103t	4	E	Genel Yetenek 	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4r00gshk8cthwlw024	cmpwtb2xy006uhkwpk9nf103t	5	C	Genel Yetenek 	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4r00gthk8cpyd86160	cmpwtb2xy006uhkwpk9nf103t	6	A	Genel Yetenek 	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4r00guhk8cnxet67jr	cmpwtb2xy006uhkwpk9nf103t	7	E	Genel Yetenek 	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4r00gvhk8cw9a8urtt	cmpwtb2xy006uhkwpk9nf103t	8	A	Genel Yetenek 	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4r00gwhk8ch10lla9b	cmpwtb2xy006uhkwpk9nf103t	9	E	Genel Yetenek 	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4r00gxhk8cry4aek0x	cmpwtb2xy006uhkwpk9nf103t	10	B	Genel Yetenek 	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4r00gyhk8ctilhceo6	cmpwtb2xy006uhkwpk9nf103t	11	E	Genel Yetenek 	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmq0qinr001jyhk8dzfrjihs4	cmp5jiu2e0019hkntf5ix2t9l	15	B	MUHASEBE	2026-06-05 09:41:31.451	2026-06-05 09:41:31.451	0.2	\N
cmq0qinr001jzhk8dy8msy1aa	cmp5jiu2e0019hkntf5ix2t9l	16	E	MUHASEBE	2026-06-05 09:41:31.451	2026-06-05 09:41:31.451	0.2	\N
cmq0qinr001k0hk8d4jzphhtw	cmp5jiu2e0019hkntf5ix2t9l	17	B	MUHASEBE	2026-06-05 09:41:31.451	2026-06-05 09:41:31.451	0.2	\N
cmq0qinr001k1hk8ds7q7xcwd	cmp5jiu2e0019hkntf5ix2t9l	18	D	MUHASEBE	2026-06-05 09:41:31.451	2026-06-05 09:41:31.451	0.2	\N
cmq0qinr001k2hk8du78rvrnv	cmp5jiu2e0019hkntf5ix2t9l	19	D	MUHASEBE	2026-06-05 09:41:31.451	2026-06-05 09:41:31.451	0.2	\N
cmq0qinr001k3hk8dzem8awpz	cmp5jiu2e0019hkntf5ix2t9l	20	A	MUHASEBE	2026-06-05 09:41:31.451	2026-06-05 09:41:31.451	0.2	\N
cmq0qinr001k4hk8dwku7lshg	cmp5jiu2e0019hkntf5ix2t9l	21	E	MUHASEBE	2026-06-05 09:41:31.451	2026-06-05 09:41:31.451	0.2	\N
cmq0qinr001k5hk8db5cok3k2	cmp5jiu2e0019hkntf5ix2t9l	22	C	MUHASEBE	2026-06-05 09:41:31.451	2026-06-05 09:41:31.451	0.2	\N
cmq0qinr001k6hk8d8kcs3p4o	cmp5jiu2e0019hkntf5ix2t9l	23	D	MUHASEBE	2026-06-05 09:41:31.451	2026-06-05 09:41:31.451	0.2	\N
cmq0pgwhd00jrhk8dy9yeh04r	cmpxw01dc00k5hke61wbi7nqp	32	C	Genel Test	2026-06-05 09:12:09.84	2026-06-05 09:12:09.84	0.1	\N
cmq0pgwhd00jshk8dr8ypor8m	cmpxw01dc00k5hke61wbi7nqp	33	B	Genel Test	2026-06-05 09:12:09.84	2026-06-05 09:12:09.84	0.1	\N
cmq0pgwhd00jthk8dn3t7n7te	cmpxw01dc00k5hke61wbi7nqp	34	D	Genel Test	2026-06-05 09:12:09.84	2026-06-05 09:12:09.84	0.1	\N
cmq0pgwhd00juhk8dr23m7xsx	cmpxw01dc00k5hke61wbi7nqp	35	A	Genel Test	2026-06-05 09:12:09.84	2026-06-05 09:12:09.84	0.1	\N
cmq0pgwhd00jvhk8dvf0ii9x2	cmpxw01dc00k5hke61wbi7nqp	36	A	Genel Test	2026-06-05 09:12:09.84	2026-06-05 09:12:09.84	0.1	\N
cmq0pgwhd00jwhk8dn8ttms3i	cmpxw01dc00k5hke61wbi7nqp	37	C	Genel Test	2026-06-05 09:12:09.84	2026-06-05 09:12:09.84	0.1	\N
cmq0pgwhd00jxhk8d707nkev2	cmpxw01dc00k5hke61wbi7nqp	38	A	Genel Test	2026-06-05 09:12:09.84	2026-06-05 09:12:09.84	0.1	\N
cmq0pgwhd00jyhk8dj3u6h6yp	cmpxw01dc00k5hke61wbi7nqp	39	D	Genel Test	2026-06-05 09:12:09.84	2026-06-05 09:12:09.84	0.1	\N
cmq0pgwhd00jzhk8d66pxkb0k	cmpxw01dc00k5hke61wbi7nqp	40	A	Genel Test	2026-06-05 09:12:09.84	2026-06-05 09:12:09.84	0.1	\N
cmq0qinr001k7hk8dxoakpg7b	cmp5jiu2e0019hkntf5ix2t9l	24	B	MUHASEBE	2026-06-05 09:41:31.451	2026-06-05 09:41:31.451	0.2	\N
cmq0qinr001k8hk8dujgxc67c	cmp5jiu2e0019hkntf5ix2t9l	25	D	MUHASEBE	2026-06-05 09:41:31.451	2026-06-05 09:41:31.451	0.2	\N
cmq0qinr001k9hk8d0gl8954v	cmp5jiu2e0019hkntf5ix2t9l	26	E	MUHASEBE	2026-06-05 09:41:31.451	2026-06-05 09:41:31.451	0.2	\N
cmq0qinr001kahk8dynktss3i	cmp5jiu2e0019hkntf5ix2t9l	27	A	MUHASEBE	2026-06-05 09:41:31.451	2026-06-05 09:41:31.451	0.2	\N
cmq0qinr001kbhk8da52prsvr	cmp5jiu2e0019hkntf5ix2t9l	28	E	MUHASEBE	2026-06-05 09:41:31.451	2026-06-05 09:41:31.451	0.2	\N
cmq0qinr001kchk8d4ang37o5	cmp5jiu2e0019hkntf5ix2t9l	29	B	MUHASEBE	2026-06-05 09:41:31.451	2026-06-05 09:41:31.451	0.2	\N
cmq0qinr001kdhk8d9z4w15qr	cmp5jiu2e0019hkntf5ix2t9l	30	B	MUHASEBE	2026-06-05 09:41:31.451	2026-06-05 09:41:31.451	0.2	\N
cmq0qinr001kehk8dshte1xfm	cmp5jiu2e0019hkntf5ix2t9l	31	A	MUHASEBE	2026-06-05 09:41:31.451	2026-06-05 09:41:31.451	0.2	\N
cmq0qinr001kfhk8d0fhbcuyp	cmp5jiu2e0019hkntf5ix2t9l	32	D	MUHASEBE	2026-06-05 09:41:31.451	2026-06-05 09:41:31.451	0.2	\N
cmq0qinr001kghk8dvob10lqk	cmp5jiu2e0019hkntf5ix2t9l	33	A	MUHASEBE	2026-06-05 09:41:31.451	2026-06-05 09:41:31.451	0.2	\N
cmq0qinr001khhk8de4ze74ke	cmp5jiu2e0019hkntf5ix2t9l	34	B	MUHASEBE	2026-06-05 09:41:31.451	2026-06-05 09:41:31.451	0.2	\N
cmq0qinr001kihk8duqop2wyu	cmp5jiu2e0019hkntf5ix2t9l	35	D	MUHASEBE	2026-06-05 09:41:31.451	2026-06-05 09:41:31.451	0.2	\N
cmq0qinr001kjhk8dzkqdilkn	cmp5jiu2e0019hkntf5ix2t9l	36	B	MUHASEBE	2026-06-05 09:41:31.451	2026-06-05 09:41:31.451	0.2	\N
cmq0qinr001kkhk8ddcxmhten	cmp5jiu2e0019hkntf5ix2t9l	37	C	MUHASEBE	2026-06-05 09:41:31.451	2026-06-05 09:41:31.451	0.2	\N
cmq0qinr001klhk8d696ahgjy	cmp5jiu2e0019hkntf5ix2t9l	38	D	MUHASEBE	2026-06-05 09:41:31.451	2026-06-05 09:41:31.451	0.2	\N
cmq0qinr001kmhk8dqfz2xnnt	cmp5jiu2e0019hkntf5ix2t9l	39	C	MUHASEBE	2026-06-05 09:41:31.451	2026-06-05 09:41:31.451	0.2	\N
cmq0qinr001knhk8du36gnsmg	cmp5jiu2e0019hkntf5ix2t9l	40	A	MUHASEBE	2026-06-05 09:41:31.451	2026-06-05 09:41:31.451	0.2	\N
cmq0qj1se01kohk8duv8l9f4s	cmp5j8xvh0002hkntbvhrqecu	1	C	MALİYE	2026-06-05 09:41:49.646	2026-06-05 09:41:49.646	0.2	\N
cmq0qj1se01kphk8dqunzqctq	cmp5j8xvh0002hkntbvhrqecu	2	D	MALİYE	2026-06-05 09:41:49.646	2026-06-05 09:41:49.646	0.2	\N
cmq0qj1se01kqhk8du43ltip3	cmp5j8xvh0002hkntbvhrqecu	3	A	MALİYE	2026-06-05 09:41:49.646	2026-06-05 09:41:49.646	0.2	\N
cmq0qj1se01krhk8dr2o3b6qo	cmp5j8xvh0002hkntbvhrqecu	4	B	MALİYE	2026-06-05 09:41:49.646	2026-06-05 09:41:49.646	0.2	\N
cmq0qj1se01kshk8dwx2hcr1k	cmp5j8xvh0002hkntbvhrqecu	5	D	MALİYE	2026-06-05 09:41:49.646	2026-06-05 09:41:49.646	0.2	\N
cmq0qj1se01kthk8dupjjha36	cmp5j8xvh0002hkntbvhrqecu	6	B	MALİYE	2026-06-05 09:41:49.646	2026-06-05 09:41:49.646	0.2	\N
cmq0qj1se01kuhk8dbmr179qp	cmp5j8xvh0002hkntbvhrqecu	7	D	MALİYE	2026-06-05 09:41:49.646	2026-06-05 09:41:49.646	0.2	\N
cmq0qj1se01kvhk8dpzyykshk	cmp5j8xvh0002hkntbvhrqecu	8	B	MALİYE	2026-06-05 09:41:49.646	2026-06-05 09:41:49.646	0.2	\N
cmq0qj1se01kwhk8dbqlzlphw	cmp5j8xvh0002hkntbvhrqecu	9	A	MALİYE	2026-06-05 09:41:49.646	2026-06-05 09:41:49.646	0.2	\N
cmq0qj1se01kxhk8djm81gzkc	cmp5j8xvh0002hkntbvhrqecu	10	B	MALİYE	2026-06-05 09:41:49.646	2026-06-05 09:41:49.646	0.2	\N
cmq0qj1se01kyhk8dnxueoylk	cmp5j8xvh0002hkntbvhrqecu	11	D	MALİYE	2026-06-05 09:41:49.646	2026-06-05 09:41:49.646	0.2	\N
cmq0qj1se01kzhk8ds4ew90nu	cmp5j8xvh0002hkntbvhrqecu	12	B	MALİYE	2026-06-05 09:41:49.646	2026-06-05 09:41:49.646	0.2	\N
cmq0qj1se01l0hk8dht9r1ouj	cmp5j8xvh0002hkntbvhrqecu	13	E	MALİYE	2026-06-05 09:41:49.646	2026-06-05 09:41:49.646	0.2	\N
cmq0qj1se01l1hk8d8h526jli	cmp5j8xvh0002hkntbvhrqecu	14	C	MALİYE	2026-06-05 09:41:49.646	2026-06-05 09:41:49.646	0.2	\N
cmq0qj1se01l2hk8d3v1clh7q	cmp5j8xvh0002hkntbvhrqecu	15	A	MALİYE	2026-06-05 09:41:49.646	2026-06-05 09:41:49.646	0.2	\N
cmq0qj1se01l3hk8d2r4o9slr	cmp5j8xvh0002hkntbvhrqecu	16	D	MALİYE	2026-06-05 09:41:49.646	2026-06-05 09:41:49.646	0.2	\N
cmq0qj1se01l4hk8d4uf22ow8	cmp5j8xvh0002hkntbvhrqecu	17	C	MALİYE	2026-06-05 09:41:49.646	2026-06-05 09:41:49.646	0.2	\N
cmq0qj1se01l5hk8d6tecv159	cmp5j8xvh0002hkntbvhrqecu	18	D	MALİYE	2026-06-05 09:41:49.646	2026-06-05 09:41:49.646	0.2	\N
cmq0qj1se01l6hk8dn0fv8ojp	cmp5j8xvh0002hkntbvhrqecu	19	A	MALİYE	2026-06-05 09:41:49.646	2026-06-05 09:41:49.646	0.2	\N
cmq0qj1se01l7hk8dyi84itba	cmp5j8xvh0002hkntbvhrqecu	20	D	MALİYE	2026-06-05 09:41:49.646	2026-06-05 09:41:49.646	0.2	\N
cmq0qj1se01l8hk8d6jf6ehip	cmp5j8xvh0002hkntbvhrqecu	21	D	MALİYE	2026-06-05 09:41:49.646	2026-06-05 09:41:49.646	0.2	\N
cmq0qj1se01l9hk8dx9yj7kew	cmp5j8xvh0002hkntbvhrqecu	22	E	MALİYE	2026-06-05 09:41:49.646	2026-06-05 09:41:49.646	0.2	\N
cmq0qj1se01lahk8d0yqhmm0k	cmp5j8xvh0002hkntbvhrqecu	23	D	MALİYE	2026-06-05 09:41:49.646	2026-06-05 09:41:49.646	0.2	\N
cmq0qj1se01lbhk8d99wktw2r	cmp5j8xvh0002hkntbvhrqecu	24	B	MALİYE	2026-06-05 09:41:49.646	2026-06-05 09:41:49.646	0.2	\N
cmq0qj1se01lchk8dn0e7db7k	cmp5j8xvh0002hkntbvhrqecu	25	D	MALİYE	2026-06-05 09:41:49.646	2026-06-05 09:41:49.646	0.2	\N
cmq0qj1se01ldhk8djpjto1av	cmp5j8xvh0002hkntbvhrqecu	26	E	MALİYE	2026-06-05 09:41:49.646	2026-06-05 09:41:49.646	0.2	\N
cmq0qj1se01lehk8dzub59irz	cmp5j8xvh0002hkntbvhrqecu	27	D	MALİYE	2026-06-05 09:41:49.646	2026-06-05 09:41:49.646	0.2	\N
cmq0qj1se01lfhk8da9am7238	cmp5j8xvh0002hkntbvhrqecu	28	B	MALİYE	2026-06-05 09:41:49.646	2026-06-05 09:41:49.646	0.2	\N
cmq0qj1se01lghk8de7mp7pf3	cmp5j8xvh0002hkntbvhrqecu	29	A	MALİYE	2026-06-05 09:41:49.646	2026-06-05 09:41:49.646	0.2	\N
cmq0qj1se01lhhk8d19z8f0pm	cmp5j8xvh0002hkntbvhrqecu	30	A	MALİYE	2026-06-05 09:41:49.646	2026-06-05 09:41:49.646	0.2	\N
cmpzkik4r00gzhk8c1chrboeh	cmpwtb2xy006uhkwpk9nf103t	12	B	Genel Yetenek 	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4r00h0hk8c9lstuqpj	cmpwtb2xy006uhkwpk9nf103t	13	D	Genel Yetenek 	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4r00h1hk8czebbzl4t	cmpwtb2xy006uhkwpk9nf103t	14	E	Genel Yetenek 	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4r00h2hk8ce08p4zvi	cmpwtb2xy006uhkwpk9nf103t	15	D	Genel Yetenek 	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4r00h3hk8cw9rn5mmf	cmpwtb2xy006uhkwpk9nf103t	16	C	Genel Yetenek 	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4r00h4hk8cl51zw8f7	cmpwtb2xy006uhkwpk9nf103t	17	D	Genel Yetenek 	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4r00h5hk8chy5sziay	cmpwtb2xy006uhkwpk9nf103t	18	E	Genel Yetenek 	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4r00h6hk8crxoxq6ny	cmpwtb2xy006uhkwpk9nf103t	19	B	Genel Yetenek 	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4r00h7hk8c6la28p92	cmpwtb2xy006uhkwpk9nf103t	20	B	Genel Yetenek 	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4s00h8hk8c0czabr0p	cmpwtb2xy006uhkwpk9nf103t	21	B	Genel Yetenek 	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4s00h9hk8czcx4lqab	cmpwtb2xy006uhkwpk9nf103t	22	B	Genel Yetenek 	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4s00hahk8crnibxutd	cmpwtb2xy006uhkwpk9nf103t	23	C	Genel Yetenek 	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4s00hbhk8cd6c4wter	cmpwtb2xy006uhkwpk9nf103t	24	B	Genel Yetenek 	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4s00hchk8c2hp5b16z	cmpwtb2xy006uhkwpk9nf103t	25	E	Genel Yetenek 	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4s00hdhk8ce0n9guvs	cmpwtb2xy006uhkwpk9nf103t	26	B	Genel Yetenek 	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4s00hehk8cwdtf4qav	cmpwtb2xy006uhkwpk9nf103t	27	A	Genel Yetenek 	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4s00hfhk8cv3acg5k4	cmpwtb2xy006uhkwpk9nf103t	28	D	Genel Yetenek 	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4s00hghk8coyuxyz0n	cmpwtb2xy006uhkwpk9nf103t	29	D	Genel Yetenek 	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4s00hhhk8ck5g6wu4l	cmpwtb2xy006uhkwpk9nf103t	30	C	Genel Yetenek 	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4s00hihk8cjyd4thkx	cmpwtb2xy006uhkwpk9nf103t	31	B	Genel Yetenek 	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4s00hjhk8csx3nwmwi	cmpwtb2xy006uhkwpk9nf103t	32	C	Genel Yetenek 	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4s00hkhk8c96h2eprj	cmpwtb2xy006uhkwpk9nf103t	33	A	Genel Yetenek 	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4s00hlhk8c51p4dzyx	cmpwtb2xy006uhkwpk9nf103t	34	A	Genel Yetenek 	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4s00hmhk8cmqonp8hk	cmpwtb2xy006uhkwpk9nf103t	35	E	Genel Yetenek 	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4s00hnhk8cyikiitko	cmpwtb2xy006uhkwpk9nf103t	36	C	Genel Yetenek 	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4t00hohk8c4uucivh9	cmpwtb2xy006uhkwpk9nf103t	37	A	Genel Yetenek 	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4t00hphk8cbh5i23ef	cmpwtb2xy006uhkwpk9nf103t	38	A	Genel Yetenek 	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4t00hqhk8c29t7uhp8	cmpwtb2xy006uhkwpk9nf103t	39	D	Genel Yetenek 	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4t00hrhk8cnfrjwi0m	cmpwtb2xy006uhkwpk9nf103t	40	C	Genel Yetenek 	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4t00hshk8cbnme02ew	cmpwtb2xy006uhkwpk9nf103t	41	D	Genel Yetenek 	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4t00hthk8c9c8ytgsb	cmpwtb2xy006uhkwpk9nf103t	42	A	Genel Yetenek 	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4t00huhk8cgyxoiicm	cmpwtb2xy006uhkwpk9nf103t	43	B	Genel Yetenek 	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4t00hvhk8c44g0ftre	cmpwtb2xy006uhkwpk9nf103t	44	E	Genel Yetenek 	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4t00hwhk8cyysyxhse	cmpwtb2xy006uhkwpk9nf103t	45	C	Genel Yetenek 	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4t00hxhk8co65s9hhn	cmpwtb2xy006uhkwpk9nf103t	46	D	Genel Yetenek 	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4t00hyhk8czg1oxkq7	cmpwtb2xy006uhkwpk9nf103t	47	C	Genel Yetenek 	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4t00hzhk8crog496ic	cmpwtb2xy006uhkwpk9nf103t	48	B	Genel Yetenek 	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4t00i0hk8cwijmn1an	cmpwtb2xy006uhkwpk9nf103t	49	D	Genel Yetenek 	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4t00i1hk8cq4lz3gvv	cmpwtb2xy006uhkwpk9nf103t	50	C	Genel Yetenek 	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4t00i2hk8cf3qhx5a8	cmpwtb2xy006uhkwpk9nf103t	51	C	Genel Yetenek 	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4t00i3hk8c8vzj4ryp	cmpwtb2xy006uhkwpk9nf103t	52	D	Genel Yetenek 	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4t00i4hk8cxrf2hx87	cmpwtb2xy006uhkwpk9nf103t	53	C	Genel Yetenek 	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4u00i5hk8c6yr1i6w1	cmpwtb2xy006uhkwpk9nf103t	54	B	Genel Yetenek 	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4u00i6hk8cqlmilybx	cmpwtb2xy006uhkwpk9nf103t	55	C	Genel Yetenek 	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4u00i7hk8ca9dwz2g8	cmpwtb2xy006uhkwpk9nf103t	56	C	Genel Yetenek 	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4u00i8hk8cg5p3n96l	cmpwtb2xy006uhkwpk9nf103t	57	D	Genel Yetenek 	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4u00i9hk8cf4bc1pve	cmpwtb2xy006uhkwpk9nf103t	58	D	Genel Yetenek 	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4u00iahk8czuclz9cc	cmpwtb2xy006uhkwpk9nf103t	59	A	Genel Yetenek 	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4u00ibhk8cgvr9or8b	cmpwtb2xy006uhkwpk9nf103t	60	C	Genel Yetenek 	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4u00ichk8cwr6u1kol	cmpwtb2xy006uhkwpk9nf103t	61	C	Genel Kültür	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4u00idhk8chyqg6qaw	cmpwtb2xy006uhkwpk9nf103t	62	B	Genel Kültür	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4u00iehk8cisadb9i6	cmpwtb2xy006uhkwpk9nf103t	63	A	Genel Kültür	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4u00ifhk8cfe2sf3rq	cmpwtb2xy006uhkwpk9nf103t	64	C	Genel Kültür	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4u00ighk8cj5h9ejt5	cmpwtb2xy006uhkwpk9nf103t	65	C	Genel Kültür	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4u00ihhk8ckn2xjw9f	cmpwtb2xy006uhkwpk9nf103t	66	B	Genel Kültür	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4u00iihk8cci9ic8n1	cmpwtb2xy006uhkwpk9nf103t	67	E	Genel Kültür	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4u00ijhk8c3ma32g8k	cmpwtb2xy006uhkwpk9nf103t	68	C	Genel Kültür	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4u00ikhk8cm3tidvl6	cmpwtb2xy006uhkwpk9nf103t	69	B	Genel Kültür	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4u00ilhk8chjbm7qtq	cmpwtb2xy006uhkwpk9nf103t	70	E	Genel Kültür	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4v00imhk8c5bum1oa8	cmpwtb2xy006uhkwpk9nf103t	71	C	Genel Kültür	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4v00inhk8cjvqe8j8g	cmpwtb2xy006uhkwpk9nf103t	72	A	Genel Kültür	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4v00iohk8clcyz89hv	cmpwtb2xy006uhkwpk9nf103t	73	E	Genel Kültür	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4v00iphk8cpdzj7cbb	cmpwtb2xy006uhkwpk9nf103t	74	A	Genel Kültür	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4v00iqhk8cf551nmsm	cmpwtb2xy006uhkwpk9nf103t	75	D	Genel Kültür	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4v00irhk8c53tvui4n	cmpwtb2xy006uhkwpk9nf103t	76	E	Genel Kültür	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4v00ishk8cgc932vex	cmpwtb2xy006uhkwpk9nf103t	77	A	Genel Kültür	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4v00ithk8c6fmqorv2	cmpwtb2xy006uhkwpk9nf103t	78	A	Genel Kültür	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4v00iuhk8cxjeh2vz3	cmpwtb2xy006uhkwpk9nf103t	79	C	Genel Kültür	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4v00ivhk8cr15tfskw	cmpwtb2xy006uhkwpk9nf103t	80	A	Genel Kültür	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4v00iwhk8cbha8unmi	cmpwtb2xy006uhkwpk9nf103t	81	E	Genel Kültür	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4v00ixhk8ciy1athk9	cmpwtb2xy006uhkwpk9nf103t	82	D	Genel Kültür	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4v00iyhk8cykuq9fqf	cmpwtb2xy006uhkwpk9nf103t	83	E	Genel Kültür	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4v00izhk8cgj9elypu	cmpwtb2xy006uhkwpk9nf103t	84	C	Genel Kültür	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4v00j0hk8cdaeyo6dy	cmpwtb2xy006uhkwpk9nf103t	85	E	Genel Kültür	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4v00j1hk8c16lsks4q	cmpwtb2xy006uhkwpk9nf103t	86	D	Genel Kültür	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4v00j2hk8ci14vl1r4	cmpwtb2xy006uhkwpk9nf103t	87	A	Genel Kültür	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4v00j3hk8c4u9xmkuo	cmpwtb2xy006uhkwpk9nf103t	88	D	Genel Kültür	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4v00j4hk8cvtf5vhug	cmpwtb2xy006uhkwpk9nf103t	89	A	Genel Kültür	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4v00j5hk8co617tz43	cmpwtb2xy006uhkwpk9nf103t	90	E	Genel Kültür	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4v00j6hk8cwcflr30a	cmpwtb2xy006uhkwpk9nf103t	91	A	Genel Kültür	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4v00j7hk8c7ox5hcg6	cmpwtb2xy006uhkwpk9nf103t	92	D	Genel Kültür	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4v00j8hk8cdqjc5m4l	cmpwtb2xy006uhkwpk9nf103t	93	B	Genel Kültür	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4w00j9hk8cnkcq124a	cmpwtb2xy006uhkwpk9nf103t	94	B	Genel Kültür	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4w00jahk8cfiv23p5h	cmpwtb2xy006uhkwpk9nf103t	95	A	Genel Kültür	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4w00jbhk8ce16i1ceo	cmpwtb2xy006uhkwpk9nf103t	96	E	Genel Kültür	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4w00jchk8coambi2ze	cmpwtb2xy006uhkwpk9nf103t	97	C	Genel Kültür	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4w00jdhk8cqi3ec9kg	cmpwtb2xy006uhkwpk9nf103t	98	D	Genel Kültür	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4w00jehk8cq2zvxtbc	cmpwtb2xy006uhkwpk9nf103t	99	D	Genel Kültür	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4w00jfhk8c2y0uqlqj	cmpwtb2xy006uhkwpk9nf103t	100	B	Genel Kültür	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4w00jghk8c0rljjoe8	cmpwtb2xy006uhkwpk9nf103t	101	C	Genel Kültür	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4w00jhhk8cx9y17ynt	cmpwtb2xy006uhkwpk9nf103t	102	D	Genel Kültür	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4w00jihk8c27q3drmn	cmpwtb2xy006uhkwpk9nf103t	103	A	Genel Kültür	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4w00jjhk8cxux53dfl	cmpwtb2xy006uhkwpk9nf103t	104	A	Genel Kültür	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4w00jkhk8cubl1ftou	cmpwtb2xy006uhkwpk9nf103t	105	D	Genel Kültür	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4w00jlhk8c4e4kvick	cmpwtb2xy006uhkwpk9nf103t	106	D	Genel Kültür	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4w00jmhk8cgpg5gulv	cmpwtb2xy006uhkwpk9nf103t	107	D	Genel Kültür	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4w00jnhk8cr4mbxan6	cmpwtb2xy006uhkwpk9nf103t	108	B	Genel Kültür	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4w00johk8czn2t1ss7	cmpwtb2xy006uhkwpk9nf103t	109	C	Genel Kültür	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4w00jphk8cls043wte	cmpwtb2xy006uhkwpk9nf103t	110	E	Genel Kültür	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4w00jqhk8cqaxamy0n	cmpwtb2xy006uhkwpk9nf103t	111	D	Genel Kültür	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4x00jrhk8cjfe9oz8y	cmpwtb2xy006uhkwpk9nf103t	112	A	Genel Kültür	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4x00jshk8c7fhnmjw8	cmpwtb2xy006uhkwpk9nf103t	113	C	Genel Kültür	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmq0qj1se01lihk8droudlhg4	cmp5j8xvh0002hkntbvhrqecu	31	D	MALİYE	2026-06-05 09:41:49.646	2026-06-05 09:41:49.646	0.2	\N
cmq0qj1se01ljhk8dlar8d3sg	cmp5j8xvh0002hkntbvhrqecu	32	C	MALİYE	2026-06-05 09:41:49.646	2026-06-05 09:41:49.646	0.2	\N
cmq0qj1se01lkhk8dyd04v4fv	cmp5j8xvh0002hkntbvhrqecu	33	D	MALİYE	2026-06-05 09:41:49.646	2026-06-05 09:41:49.646	0.2	\N
cmq0qj1se01llhk8dso8ldevk	cmp5j8xvh0002hkntbvhrqecu	34	C	MALİYE	2026-06-05 09:41:49.646	2026-06-05 09:41:49.646	0.2	\N
cmq0qj1se01lmhk8d77w88y7u	cmp5j8xvh0002hkntbvhrqecu	35	D	MALİYE	2026-06-05 09:41:49.646	2026-06-05 09:41:49.646	0.2	\N
cmq0qj1se01lnhk8drwrf0i9y	cmp5j8xvh0002hkntbvhrqecu	36	D	MALİYE	2026-06-05 09:41:49.646	2026-06-05 09:41:49.646	0.2	\N
cmq0qj1se01lohk8d27m9xbrp	cmp5j8xvh0002hkntbvhrqecu	37	D	MALİYE	2026-06-05 09:41:49.646	2026-06-05 09:41:49.646	0.2	\N
cmq0qj1se01lphk8dgk4q3tjy	cmp5j8xvh0002hkntbvhrqecu	38	D	MALİYE	2026-06-05 09:41:49.646	2026-06-05 09:41:49.646	0.2	\N
cmq0qj1se01lqhk8dv2nfew5n	cmp5j8xvh0002hkntbvhrqecu	39	C	MALİYE	2026-06-05 09:41:49.646	2026-06-05 09:41:49.646	0.2	\N
cmq0qj1se01lrhk8dri1al584	cmp5j8xvh0002hkntbvhrqecu	40	A	MALİYE	2026-06-05 09:41:49.646	2026-06-05 09:41:49.646	0.2	\N
cmq0qjntp01lshk8dgcskiotx	cmp45g62r00pshk447kwwuu5q	1	C	HUKUH	2026-06-05 09:42:18.203	2026-06-05 09:42:18.203	0.2	\N
cmq0qjntp01lthk8dcxu0114y	cmp45g62r00pshk447kwwuu5q	2	D	HUKUH	2026-06-05 09:42:18.203	2026-06-05 09:42:18.203	0.2	\N
cmq0qjntp01luhk8dmglcbg2t	cmp45g62r00pshk447kwwuu5q	3	C	HUKUH	2026-06-05 09:42:18.203	2026-06-05 09:42:18.203	0.2	\N
cmq0qjntp01lvhk8d9n8nwe32	cmp45g62r00pshk447kwwuu5q	4	C	HUKUH	2026-06-05 09:42:18.203	2026-06-05 09:42:18.203	0.2	\N
cmq0qjntp01lwhk8dyf45hy6j	cmp45g62r00pshk447kwwuu5q	5	A	HUKUH	2026-06-05 09:42:18.203	2026-06-05 09:42:18.203	0.2	\N
cmq0qjntp01lxhk8dmeuojfd3	cmp45g62r00pshk447kwwuu5q	6	E	HUKUH	2026-06-05 09:42:18.203	2026-06-05 09:42:18.203	0.2	\N
cmq0qjntp01lyhk8diw5i71qr	cmp45g62r00pshk447kwwuu5q	7	D	HUKUH	2026-06-05 09:42:18.203	2026-06-05 09:42:18.203	0.2	\N
cmq0qjntp01lzhk8dzjxcmbkw	cmp45g62r00pshk447kwwuu5q	8	D	HUKUH	2026-06-05 09:42:18.203	2026-06-05 09:42:18.203	0.2	\N
cmq0qjntp01m0hk8dm21t3pd5	cmp45g62r00pshk447kwwuu5q	9	E	HUKUH	2026-06-05 09:42:18.203	2026-06-05 09:42:18.203	0.2	\N
cmq0qjntp01m1hk8dxiy5v3k8	cmp45g62r00pshk447kwwuu5q	10	E	HUKUH	2026-06-05 09:42:18.203	2026-06-05 09:42:18.203	0.2	\N
cmq0qjntp01m2hk8d00nftr80	cmp45g62r00pshk447kwwuu5q	11	B	HUKUH	2026-06-05 09:42:18.203	2026-06-05 09:42:18.203	0.2	\N
cmq0qjntp01m3hk8dgoaog2xe	cmp45g62r00pshk447kwwuu5q	12	E	HUKUH	2026-06-05 09:42:18.203	2026-06-05 09:42:18.203	0.2	\N
cmq0qjntp01m4hk8d1cq5n4fy	cmp45g62r00pshk447kwwuu5q	13	C	HUKUH	2026-06-05 09:42:18.203	2026-06-05 09:42:18.203	0.2	\N
cmq0qjntp01m5hk8dx9cxi5y8	cmp45g62r00pshk447kwwuu5q	14	D	HUKUH	2026-06-05 09:42:18.203	2026-06-05 09:42:18.203	0.2	\N
cmq0qjntp01m6hk8d5wmovtgp	cmp45g62r00pshk447kwwuu5q	15	E	HUKUH	2026-06-05 09:42:18.203	2026-06-05 09:42:18.203	0.2	\N
cmq0qjntp01m7hk8d0pig5ou1	cmp45g62r00pshk447kwwuu5q	16	D	HUKUH	2026-06-05 09:42:18.203	2026-06-05 09:42:18.203	0.2	\N
cmq0qjntp01m8hk8daf9ch2l1	cmp45g62r00pshk447kwwuu5q	17	A	HUKUH	2026-06-05 09:42:18.203	2026-06-05 09:42:18.203	0.2	\N
cmq0qjntp01m9hk8dls1h98rt	cmp45g62r00pshk447kwwuu5q	18	B	HUKUH	2026-06-05 09:42:18.203	2026-06-05 09:42:18.203	0.2	\N
cmq0qjntp01mahk8d3f5f4ej5	cmp45g62r00pshk447kwwuu5q	19	C	HUKUH	2026-06-05 09:42:18.203	2026-06-05 09:42:18.203	0.2	\N
cmq0qjntp01mbhk8dub10wij3	cmp45g62r00pshk447kwwuu5q	20	B	HUKUH	2026-06-05 09:42:18.203	2026-06-05 09:42:18.203	0.2	\N
cmq0qjntp01mchk8dzg57kdsk	cmp45g62r00pshk447kwwuu5q	21	C	HUKUH	2026-06-05 09:42:18.203	2026-06-05 09:42:18.203	0.2	\N
cmq0qjntp01mdhk8dqkocz03m	cmp45g62r00pshk447kwwuu5q	22	C	HUKUH	2026-06-05 09:42:18.203	2026-06-05 09:42:18.203	0.2	\N
cmq0qjntp01mehk8dlyfiy6uq	cmp45g62r00pshk447kwwuu5q	23	E	HUKUH	2026-06-05 09:42:18.203	2026-06-05 09:42:18.203	0.2	\N
cmq0qjntp01mfhk8dufoepfn8	cmp45g62r00pshk447kwwuu5q	24	D	HUKUH	2026-06-05 09:42:18.203	2026-06-05 09:42:18.203	0.2	\N
cmq0qjntp01mghk8d8adehqmu	cmp45g62r00pshk447kwwuu5q	25	B	HUKUH	2026-06-05 09:42:18.203	2026-06-05 09:42:18.203	0.2	\N
cmq0qjntp01mhhk8d8pm3v9vl	cmp45g62r00pshk447kwwuu5q	26	B	HUKUH	2026-06-05 09:42:18.203	2026-06-05 09:42:18.203	0.2	\N
cmq0pnawm012thk8d6eszqxnh	cmpwufjvi00eyhkwp5jo44dff	38	C	Genel Test	2026-06-05 09:17:08.468	2026-06-05 09:17:08.468	0.2	\N
cmq0pnawm012uhk8d0gcbq58m	cmpwufjvi00eyhkwp5jo44dff	39	E	Genel Test	2026-06-05 09:17:08.468	2026-06-05 09:17:08.468	0.2	\N
cmq0pnawm012vhk8da3woibdb	cmpwufjvi00eyhkwp5jo44dff	40	A	Genel Test	2026-06-05 09:17:08.468	2026-06-05 09:17:08.468	0.2	\N
cmq0pfy9o00ephk8dbzgitkh7	cmpxw5zub00oshke69lnxt9hl	10	B	Genel Test	2026-06-05 09:11:25.5	2026-06-05 09:11:25.5	0.2	\N
cmq0pfy9o00eqhk8d28s4ts5r	cmpxw5zub00oshke69lnxt9hl	11	E	Genel Test	2026-06-05 09:11:25.5	2026-06-05 09:11:25.5	0.2	\N
cmq0pfy9o00erhk8dvskkd1k7	cmpxw5zub00oshke69lnxt9hl	12	D	Genel Test	2026-06-05 09:11:25.5	2026-06-05 09:11:25.5	0.2	\N
cmq0pfy9o00eshk8d6v6kc8xl	cmpxw5zub00oshke69lnxt9hl	13	A	Genel Test	2026-06-05 09:11:25.5	2026-06-05 09:11:25.5	0.2	\N
cmq0pfy9o00ethk8dna8htgrn	cmpxw5zub00oshke69lnxt9hl	14	D	Genel Test	2026-06-05 09:11:25.5	2026-06-05 09:11:25.5	0.2	\N
cmq0pfy9o00euhk8ddl5hh75p	cmpxw5zub00oshke69lnxt9hl	15	D	Genel Test	2026-06-05 09:11:25.5	2026-06-05 09:11:25.5	0.2	\N
cmq0pfy9o00evhk8dgxv48y4h	cmpxw5zub00oshke69lnxt9hl	16	A	Genel Test	2026-06-05 09:11:25.5	2026-06-05 09:11:25.5	0.2	\N
cmq0pfy9o00ewhk8d8wep9kaw	cmpxw5zub00oshke69lnxt9hl	17	B	Genel Test	2026-06-05 09:11:25.5	2026-06-05 09:11:25.5	0.2	\N
cmq0pfy9o00exhk8d38i5s1n9	cmpxw5zub00oshke69lnxt9hl	18	E	Genel Test	2026-06-05 09:11:25.5	2026-06-05 09:11:25.5	0.2	\N
cmq0pfy9p00eyhk8dzjwoahrf	cmpxw5zub00oshke69lnxt9hl	19	A	Genel Test	2026-06-05 09:11:25.5	2026-06-05 09:11:25.5	0.2	\N
cmq0pfy9p00ezhk8de3kscdxv	cmpxw5zub00oshke69lnxt9hl	20	A	Genel Test	2026-06-05 09:11:25.5	2026-06-05 09:11:25.5	0.2	\N
cmq0pfy9p00f0hk8dt5yegmdx	cmpxw5zub00oshke69lnxt9hl	21	E	Genel Test	2026-06-05 09:11:25.5	2026-06-05 09:11:25.5	0.2	\N
cmq0pfy9p00f1hk8did3d5r6h	cmpxw5zub00oshke69lnxt9hl	22	A	Genel Test	2026-06-05 09:11:25.5	2026-06-05 09:11:25.5	0.2	\N
cmq0pfy9p00f2hk8dmm8vuh3p	cmpxw5zub00oshke69lnxt9hl	23	D	Genel Test	2026-06-05 09:11:25.5	2026-06-05 09:11:25.5	0.2	\N
cmq0pfy9p00f3hk8dnxi2w6gp	cmpxw5zub00oshke69lnxt9hl	24	D	Genel Test	2026-06-05 09:11:25.5	2026-06-05 09:11:25.5	0.2	\N
cmq0pfy9p00f4hk8doiqonqgq	cmpxw5zub00oshke69lnxt9hl	25	C	Genel Test	2026-06-05 09:11:25.5	2026-06-05 09:11:25.5	0.2	\N
cmq0pfy9p00f5hk8d8s9etyxd	cmpxw5zub00oshke69lnxt9hl	26	B	Genel Test	2026-06-05 09:11:25.5	2026-06-05 09:11:25.5	0.2	\N
cmq0pfy9p00f6hk8d9f0rhni0	cmpxw5zub00oshke69lnxt9hl	27	A	Genel Test	2026-06-05 09:11:25.5	2026-06-05 09:11:25.5	0.2	\N
cmq0pfy9p00f7hk8dsc1x7zs4	cmpxw5zub00oshke69lnxt9hl	28	B	Genel Test	2026-06-05 09:11:25.5	2026-06-05 09:11:25.5	0.2	\N
cmq0pfy9p00f8hk8d6mwlzaq2	cmpxw5zub00oshke69lnxt9hl	29	A	Genel Test	2026-06-05 09:11:25.5	2026-06-05 09:11:25.5	0.2	\N
cmq0pfy9p00f9hk8d47m498q6	cmpxw5zub00oshke69lnxt9hl	30	B	Genel Test	2026-06-05 09:11:25.5	2026-06-05 09:11:25.5	0.2	\N
cmq0pfy9p00fahk8duiytcz27	cmpxw5zub00oshke69lnxt9hl	31	C	Genel Test	2026-06-05 09:11:25.5	2026-06-05 09:11:25.5	0.2	\N
cmq0pfy9p00fbhk8de131g06n	cmpxw5zub00oshke69lnxt9hl	32	A	Genel Test	2026-06-05 09:11:25.5	2026-06-05 09:11:25.5	0.2	\N
cmq0pfy9p00fchk8d09c0p9am	cmpxw5zub00oshke69lnxt9hl	33	D	Genel Test	2026-06-05 09:11:25.5	2026-06-05 09:11:25.5	0.2	\N
cmq0pfy9p00fdhk8d4jv42fga	cmpxw5zub00oshke69lnxt9hl	34	E	Genel Test	2026-06-05 09:11:25.5	2026-06-05 09:11:25.5	0.2	\N
cmq0pfy9p00fehk8dkn64hrr7	cmpxw5zub00oshke69lnxt9hl	35	B	Genel Test	2026-06-05 09:11:25.5	2026-06-05 09:11:25.5	0.2	\N
cmq0pfy9p00ffhk8dr87ctez9	cmpxw5zub00oshke69lnxt9hl	36	C	Genel Test	2026-06-05 09:11:25.5	2026-06-05 09:11:25.5	0.2	\N
cmq0pfy9p00fghk8duuai60kl	cmpxw5zub00oshke69lnxt9hl	37	C	Genel Test	2026-06-05 09:11:25.5	2026-06-05 09:11:25.5	0.2	\N
cmq0pfy9p00fhhk8dgt71nhdo	cmpxw5zub00oshke69lnxt9hl	38	B	Genel Test	2026-06-05 09:11:25.5	2026-06-05 09:11:25.5	0.2	\N
cmq0pfy9p00fihk8deg09vd59	cmpxw5zub00oshke69lnxt9hl	39	C	Genel Test	2026-06-05 09:11:25.5	2026-06-05 09:11:25.5	0.2	\N
cmq0pfy9p00fjhk8d236a8f4g	cmpxw5zub00oshke69lnxt9hl	40	E	Genel Test	2026-06-05 09:11:25.5	2026-06-05 09:11:25.5	0.2	\N
cmq0pgghq00fkhk8dexrr1xru	cmpxw4fdb00ldhke6mjnc94ez	1	B	Genel Yetenek 	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0qjntp01mihk8dew7a3ixn	cmp45g62r00pshk447kwwuu5q	27	B	HUKUH	2026-06-05 09:42:18.203	2026-06-05 09:42:18.203	0.2	\N
cmq0qjntp01mjhk8d2irj5z7f	cmp45g62r00pshk447kwwuu5q	28	C	HUKUH	2026-06-05 09:42:18.203	2026-06-05 09:42:18.203	0.2	\N
cmq0ojjnd0000hk8dw2m5ruxa	cmp46ome900s3hk44i4eqvhx8	1	E	İKTİSAT	2026-06-05 08:46:13.561	2026-06-05 08:46:13.561	0.2	\N
cmq0ph9xk00k0hk8d4xb2effn	cmpxvy55s00iyhke6ha2zs62d	1	B	Genel Test	2026-06-05 09:12:27.272	2026-06-05 09:12:27.272	0.1	\N
cmq0ph9xk00k1hk8dyd0201ht	cmpxvy55s00iyhke6ha2zs62d	2	C	Genel Test	2026-06-05 09:12:27.272	2026-06-05 09:12:27.272	0.1	\N
cmq0ph9xk00k2hk8d8lc7d1sx	cmpxvy55s00iyhke6ha2zs62d	3	D	Genel Test	2026-06-05 09:12:27.272	2026-06-05 09:12:27.272	0.1	\N
cmq0ph9xk00k3hk8dsk875szc	cmpxvy55s00iyhke6ha2zs62d	4	E	Genel Test	2026-06-05 09:12:27.272	2026-06-05 09:12:27.272	0.1	\N
cmq0ph9xk00k4hk8d71qcrm2t	cmpxvy55s00iyhke6ha2zs62d	5	C	Genel Test	2026-06-05 09:12:27.272	2026-06-05 09:12:27.272	0.1	\N
cmq0ph9xk00k5hk8d0kbdj8mf	cmpxvy55s00iyhke6ha2zs62d	6	B	Genel Test	2026-06-05 09:12:27.272	2026-06-05 09:12:27.272	0.1	\N
cmq0ph9xk00k6hk8deg0u698h	cmpxvy55s00iyhke6ha2zs62d	7	E	Genel Test	2026-06-05 09:12:27.272	2026-06-05 09:12:27.272	0.1	\N
cmq0ph9xk00k7hk8d5yixur6y	cmpxvy55s00iyhke6ha2zs62d	8	B	Genel Test	2026-06-05 09:12:27.272	2026-06-05 09:12:27.272	0.1	\N
cmq0ph9xk00k8hk8dmp30zb1x	cmpxvy55s00iyhke6ha2zs62d	9	A	Genel Test	2026-06-05 09:12:27.272	2026-06-05 09:12:27.272	0.1	\N
cmq0ph9xk00k9hk8d72mbrxfd	cmpxvy55s00iyhke6ha2zs62d	10	D	Genel Test	2026-06-05 09:12:27.272	2026-06-05 09:12:27.272	0.1	\N
cmq0ph9xl00kahk8d6b0ihi4n	cmpxvy55s00iyhke6ha2zs62d	11	C	Genel Test	2026-06-05 09:12:27.272	2026-06-05 09:12:27.272	0.1	\N
cmq0ph9xl00kbhk8d0952dqcv	cmpxvy55s00iyhke6ha2zs62d	12	D	Genel Test	2026-06-05 09:12:27.272	2026-06-05 09:12:27.272	0.1	\N
cmq0ph9xl00kchk8dhqaq9096	cmpxvy55s00iyhke6ha2zs62d	13	C	Genel Test	2026-06-05 09:12:27.272	2026-06-05 09:12:27.272	0.1	\N
cmq0ph9xl00kdhk8d6pxhnygs	cmpxvy55s00iyhke6ha2zs62d	14	A	Genel Test	2026-06-05 09:12:27.272	2026-06-05 09:12:27.272	0.1	\N
cmq0ph9xl00kehk8d7pvwuu9z	cmpxvy55s00iyhke6ha2zs62d	15	A	Genel Test	2026-06-05 09:12:27.272	2026-06-05 09:12:27.272	0.1	\N
cmq0ph9xl00kfhk8dodxf0tze	cmpxvy55s00iyhke6ha2zs62d	16	C	Genel Test	2026-06-05 09:12:27.272	2026-06-05 09:12:27.272	0.1	\N
cmq0ph9xl00kghk8d36kky2no	cmpxvy55s00iyhke6ha2zs62d	17	A	Genel Test	2026-06-05 09:12:27.272	2026-06-05 09:12:27.272	0.1	\N
cmq0ph9xl00khhk8df0f9x1fa	cmpxvy55s00iyhke6ha2zs62d	18	C	Genel Test	2026-06-05 09:12:27.272	2026-06-05 09:12:27.272	0.1	\N
cmq0ph9xl00kihk8d4fc9arfs	cmpxvy55s00iyhke6ha2zs62d	19	A	Genel Test	2026-06-05 09:12:27.272	2026-06-05 09:12:27.272	0.1	\N
cmq0ph9xl00kjhk8d80injhgf	cmpxvy55s00iyhke6ha2zs62d	20	B	Genel Test	2026-06-05 09:12:27.272	2026-06-05 09:12:27.272	0.1	\N
cmq0ph9xl00kkhk8d9mhnrx3a	cmpxvy55s00iyhke6ha2zs62d	21	E	Genel Test	2026-06-05 09:12:27.272	2026-06-05 09:12:27.272	0.1	\N
cmq0ph9xl00klhk8d5mgo9hph	cmpxvy55s00iyhke6ha2zs62d	22	A	Genel Test	2026-06-05 09:12:27.272	2026-06-05 09:12:27.272	0.1	\N
cmq0ph9xl00kmhk8diiuu6sts	cmpxvy55s00iyhke6ha2zs62d	23	B	Genel Test	2026-06-05 09:12:27.272	2026-06-05 09:12:27.272	0.1	\N
cmq0ph9xl00knhk8dn1ji0ugt	cmpxvy55s00iyhke6ha2zs62d	24	E	Genel Test	2026-06-05 09:12:27.272	2026-06-05 09:12:27.272	0.1	\N
cmq0ph9xl00kohk8dmerfgqw3	cmpxvy55s00iyhke6ha2zs62d	25	D	Genel Test	2026-06-05 09:12:27.272	2026-06-05 09:12:27.272	0.1	\N
cmq0ph9xl00kphk8di4fxnepx	cmpxvy55s00iyhke6ha2zs62d	26	C	Genel Test	2026-06-05 09:12:27.272	2026-06-05 09:12:27.272	0.1	\N
cmq0ph9xl00kqhk8dhr11r63d	cmpxvy55s00iyhke6ha2zs62d	27	A	Genel Test	2026-06-05 09:12:27.272	2026-06-05 09:12:27.272	0.1	\N
cmq0ph9xl00krhk8dhgm584yt	cmpxvy55s00iyhke6ha2zs62d	28	B	Genel Test	2026-06-05 09:12:27.272	2026-06-05 09:12:27.272	0.1	\N
cmq0ph9xl00kshk8difzn3rm4	cmpxvy55s00iyhke6ha2zs62d	29	D	Genel Test	2026-06-05 09:12:27.272	2026-06-05 09:12:27.272	0.1	\N
cmq0ph9xl00kthk8d5ngl6ox3	cmpxvy55s00iyhke6ha2zs62d	30	A	Genel Test	2026-06-05 09:12:27.272	2026-06-05 09:12:27.272	0.1	\N
cmq0ph9xl00kuhk8duevyrz03	cmpxvy55s00iyhke6ha2zs62d	31	D	Genel Test	2026-06-05 09:12:27.272	2026-06-05 09:12:27.272	0.1	\N
cmq0ph9xl00kvhk8db803kqf8	cmpxvy55s00iyhke6ha2zs62d	32	E	Genel Test	2026-06-05 09:12:27.272	2026-06-05 09:12:27.272	0.1	\N
cmq0ph9xl00kwhk8dc4cmlqco	cmpxvy55s00iyhke6ha2zs62d	33	D	Genel Test	2026-06-05 09:12:27.272	2026-06-05 09:12:27.272	0.1	\N
cmq0ph9xl00kxhk8dur05gum0	cmpxvy55s00iyhke6ha2zs62d	34	B	Genel Test	2026-06-05 09:12:27.272	2026-06-05 09:12:27.272	0.1	\N
cmq0ph9xl00kyhk8d0o9xqkkg	cmpxvy55s00iyhke6ha2zs62d	35	D	Genel Test	2026-06-05 09:12:27.272	2026-06-05 09:12:27.272	0.1	\N
cmq0ph9xl00kzhk8dkiwuj7af	cmpxvy55s00iyhke6ha2zs62d	36	E	Genel Test	2026-06-05 09:12:27.272	2026-06-05 09:12:27.272	0.1	\N
cmq0ph9xl00l0hk8dk53e7ffn	cmpxvy55s00iyhke6ha2zs62d	37	D	Genel Test	2026-06-05 09:12:27.272	2026-06-05 09:12:27.272	0.1	\N
cmq0ph9xl00l1hk8darvmtqe4	cmpxvy55s00iyhke6ha2zs62d	38	C	Genel Test	2026-06-05 09:12:27.272	2026-06-05 09:12:27.272	0.1	\N
cmq0ph9xl00l2hk8dbvafqpyh	cmpxvy55s00iyhke6ha2zs62d	39	D	Genel Test	2026-06-05 09:12:27.272	2026-06-05 09:12:27.272	0.1	\N
cmq0ph9xl00l3hk8dh4ejx1kp	cmpxvy55s00iyhke6ha2zs62d	40	B	Genel Test	2026-06-05 09:12:27.272	2026-06-05 09:12:27.272	0.1	\N
cmq0pnqkb012whk8d8a3xh3m8	cmpwu7wz500cnhkwpbjuja1wf	1	A	Genel Test	2026-06-05 09:17:28.763	2026-06-05 09:17:28.763	0.2	\N
cmq0pnqkb012xhk8drosdbvr6	cmpwu7wz500cnhkwpbjuja1wf	2	B	Genel Test	2026-06-05 09:17:28.763	2026-06-05 09:17:28.763	0.2	\N
cmq0pnqkb012yhk8dgg44494e	cmpwu7wz500cnhkwpbjuja1wf	3	C	Genel Test	2026-06-05 09:17:28.763	2026-06-05 09:17:28.763	0.2	\N
cmq0pnqkc012zhk8dvwse23ec	cmpwu7wz500cnhkwpbjuja1wf	4	A	Genel Test	2026-06-05 09:17:28.763	2026-06-05 09:17:28.763	0.2	\N
cmq0pnqkc0130hk8dy0ru1crs	cmpwu7wz500cnhkwpbjuja1wf	5	D	Genel Test	2026-06-05 09:17:28.763	2026-06-05 09:17:28.763	0.2	\N
cmq0pnqkc0131hk8dg3q3cyua	cmpwu7wz500cnhkwpbjuja1wf	6	A	Genel Test	2026-06-05 09:17:28.763	2026-06-05 09:17:28.763	0.2	\N
cmq0pnqkc0132hk8djr6j6lni	cmpwu7wz500cnhkwpbjuja1wf	7	B	Genel Test	2026-06-05 09:17:28.763	2026-06-05 09:17:28.763	0.2	\N
cmq0pnqkc0133hk8d6t8yhead	cmpwu7wz500cnhkwpbjuja1wf	8	E	Genel Test	2026-06-05 09:17:28.763	2026-06-05 09:17:28.763	0.2	\N
cmq0pnqkc0134hk8dnx25aozz	cmpwu7wz500cnhkwpbjuja1wf	9	A	Genel Test	2026-06-05 09:17:28.763	2026-06-05 09:17:28.763	0.2	\N
cmq0pnqkc0135hk8d8ixiw64r	cmpwu7wz500cnhkwpbjuja1wf	10	C	Genel Test	2026-06-05 09:17:28.763	2026-06-05 09:17:28.763	0.2	\N
cmq0pnqkc0136hk8dqvu2kxq2	cmpwu7wz500cnhkwpbjuja1wf	11	C	Genel Test	2026-06-05 09:17:28.763	2026-06-05 09:17:28.763	0.2	\N
cmq0pnqkc0137hk8dhcerxr7z	cmpwu7wz500cnhkwpbjuja1wf	12	B	Genel Test	2026-06-05 09:17:28.763	2026-06-05 09:17:28.763	0.2	\N
cmq0pnqkc0138hk8d6d2eucuc	cmpwu7wz500cnhkwpbjuja1wf	13	B	Genel Test	2026-06-05 09:17:28.763	2026-06-05 09:17:28.763	0.2	\N
cmq0pnqkc0139hk8dyhqwwslx	cmpwu7wz500cnhkwpbjuja1wf	14	D	Genel Test	2026-06-05 09:17:28.763	2026-06-05 09:17:28.763	0.2	\N
cmq0pnqkc013ahk8dt9yc2csu	cmpwu7wz500cnhkwpbjuja1wf	15	C	Genel Test	2026-06-05 09:17:28.763	2026-06-05 09:17:28.763	0.2	\N
cmq0pnqkc013bhk8dzdjftfhl	cmpwu7wz500cnhkwpbjuja1wf	16	A	Genel Test	2026-06-05 09:17:28.763	2026-06-05 09:17:28.763	0.2	\N
cmq0pnqkc013chk8d21dvm3ln	cmpwu7wz500cnhkwpbjuja1wf	17	C	Genel Test	2026-06-05 09:17:28.763	2026-06-05 09:17:28.763	0.2	\N
cmq0pnqkc013dhk8dwgyjwh9b	cmpwu7wz500cnhkwpbjuja1wf	18	C	Genel Test	2026-06-05 09:17:28.763	2026-06-05 09:17:28.763	0.2	\N
cmq0pnqkc013ehk8d3ul9r53a	cmpwu7wz500cnhkwpbjuja1wf	19	B	Genel Test	2026-06-05 09:17:28.763	2026-06-05 09:17:28.763	0.2	\N
cmq0pnqkc013fhk8dgj80qjtm	cmpwu7wz500cnhkwpbjuja1wf	20	D	Genel Test	2026-06-05 09:17:28.763	2026-06-05 09:17:28.763	0.2	\N
cmq0qjntq01mkhk8d2yj3wvqr	cmp45g62r00pshk447kwwuu5q	29	D	HUKUH	2026-06-05 09:42:18.203	2026-06-05 09:42:18.203	0.2	\N
cmq0qjntq01mlhk8dv9hicjo0	cmp45g62r00pshk447kwwuu5q	30	E	HUKUH	2026-06-05 09:42:18.203	2026-06-05 09:42:18.203	0.2	\N
cmq0qjntq01mmhk8dq76m841p	cmp45g62r00pshk447kwwuu5q	31	C	HUKUH	2026-06-05 09:42:18.203	2026-06-05 09:42:18.203	0.2	\N
cmpzkik4x00jthk8c0zu8hul3	cmpwtb2xy006uhkwpk9nf103t	114	A	Genel Kültür	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4x00juhk8c3wkmon2s	cmpwtb2xy006uhkwpk9nf103t	115	A	Genel Kültür	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4x00jvhk8cim9h5nad	cmpwtb2xy006uhkwpk9nf103t	116	A	Genel Kültür	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4x00jwhk8c6kojkex3	cmpwtb2xy006uhkwpk9nf103t	117	D	Genel Kültür	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4x00jxhk8c60zfdbet	cmpwtb2xy006uhkwpk9nf103t	118	D	Genel Kültür	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4x00jyhk8ctss0fcec	cmpwtb2xy006uhkwpk9nf103t	119	D	Genel Kültür	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmpzkik4x00jzhk8ccfw71k18	cmpwtb2xy006uhkwpk9nf103t	120	A	Genel Kültür	2026-06-04 14:05:42.889	2026-06-04 14:05:42.889	0.1	\N
cmq0qjntq01mnhk8dft5av6sa	cmp45g62r00pshk447kwwuu5q	32	E	HUKUH	2026-06-05 09:42:18.203	2026-06-05 09:42:18.203	0.2	\N
cmq0qjntq01mohk8diydukzi8	cmp45g62r00pshk447kwwuu5q	33	D	HUKUH	2026-06-05 09:42:18.203	2026-06-05 09:42:18.203	0.2	\N
cmq0qjntq01mphk8d4e2g0ywe	cmp45g62r00pshk447kwwuu5q	34	E	HUKUH	2026-06-05 09:42:18.203	2026-06-05 09:42:18.203	0.2	\N
cmq0qjntq01mqhk8dhfz44q4f	cmp45g62r00pshk447kwwuu5q	35	A	HUKUH	2026-06-05 09:42:18.203	2026-06-05 09:42:18.203	0.2	\N
cmq0qjntq01mrhk8dysxi7yqd	cmp45g62r00pshk447kwwuu5q	36	B	HUKUH	2026-06-05 09:42:18.203	2026-06-05 09:42:18.203	0.2	\N
cmq0qjntq01mshk8drysj9578	cmp45g62r00pshk447kwwuu5q	37	C	HUKUH	2026-06-05 09:42:18.203	2026-06-05 09:42:18.203	0.2	\N
cmq0qjntq01mthk8dgcwic0te	cmp45g62r00pshk447kwwuu5q	38	D	HUKUH	2026-06-05 09:42:18.203	2026-06-05 09:42:18.203	0.2	\N
cmq0qjntq01muhk8d5865zmbo	cmp45g62r00pshk447kwwuu5q	39	C	HUKUH	2026-06-05 09:42:18.203	2026-06-05 09:42:18.203	0.2	\N
cmq0qjntq01mvhk8dhc0chawb	cmp45g62r00pshk447kwwuu5q	40	B	HUKUH	2026-06-05 09:42:18.203	2026-06-05 09:42:18.203	0.2	\N
cmq0ojjnd0001hk8dia5urnum	cmp46ome900s3hk44i4eqvhx8	2	B	İKTİSAT	2026-06-05 08:46:13.561	2026-06-05 08:46:13.561	0.2	\N
cmq0ojjnd0002hk8dgd90n9wp	cmp46ome900s3hk44i4eqvhx8	3	C	İKTİSAT	2026-06-05 08:46:13.561	2026-06-05 08:46:13.561	0.2	\N
cmq0ojjnd0003hk8d6gy0iqe9	cmp46ome900s3hk44i4eqvhx8	4	A	İKTİSAT	2026-06-05 08:46:13.561	2026-06-05 08:46:13.561	0.2	\N
cmq0ojjnd0004hk8d6j5215xc	cmp46ome900s3hk44i4eqvhx8	5	D	İKTİSAT	2026-06-05 08:46:13.561	2026-06-05 08:46:13.561	0.2	\N
cmq0ojjnd0005hk8dr2f2ittt	cmp46ome900s3hk44i4eqvhx8	6	D	İKTİSAT	2026-06-05 08:46:13.561	2026-06-05 08:46:13.561	0.2	\N
cmq0ojjnd0006hk8dqjs1c4m7	cmp46ome900s3hk44i4eqvhx8	7	B	İKTİSAT	2026-06-05 08:46:13.561	2026-06-05 08:46:13.561	0.2	\N
cmq0ojjnd0007hk8djccqyr0x	cmp46ome900s3hk44i4eqvhx8	8	A	İKTİSAT	2026-06-05 08:46:13.561	2026-06-05 08:46:13.561	0.2	\N
cmq0ojjnd0008hk8dgshx4iea	cmp46ome900s3hk44i4eqvhx8	9	C	İKTİSAT	2026-06-05 08:46:13.561	2026-06-05 08:46:13.561	0.2	\N
cmq0ojjnd0009hk8den0zh9ke	cmp46ome900s3hk44i4eqvhx8	10	D	İKTİSAT	2026-06-05 08:46:13.561	2026-06-05 08:46:13.561	0.2	\N
cmq0ojjnd000ahk8dfh41wagf	cmp46ome900s3hk44i4eqvhx8	11	A	İKTİSAT	2026-06-05 08:46:13.561	2026-06-05 08:46:13.561	0.2	\N
cmq0ojjnd000bhk8dfl8krnm5	cmp46ome900s3hk44i4eqvhx8	12	B	İKTİSAT	2026-06-05 08:46:13.561	2026-06-05 08:46:13.561	0.2	\N
cmq0ojjnd000chk8d91dbop4j	cmp46ome900s3hk44i4eqvhx8	13	E	İKTİSAT	2026-06-05 08:46:13.561	2026-06-05 08:46:13.561	0.2	\N
cmq0ojjnd000dhk8d7sealr7w	cmp46ome900s3hk44i4eqvhx8	14	C	İKTİSAT	2026-06-05 08:46:13.561	2026-06-05 08:46:13.561	0.2	\N
cmq0ojjnd000ehk8dd9b8iaez	cmp46ome900s3hk44i4eqvhx8	15	D	İKTİSAT	2026-06-05 08:46:13.561	2026-06-05 08:46:13.561	0.2	\N
cmq0phz6i00l4hk8dmwskz533	cmpxvuq1d00gkhke6xmwxml94	1	A	Genel Test	2026-06-05 09:12:59.994	2026-06-05 09:12:59.994	0.2	\N
cmq0phz6i00l5hk8d2qgckcq8	cmpxvuq1d00gkhke6xmwxml94	2	A	Genel Test	2026-06-05 09:12:59.994	2026-06-05 09:12:59.994	0.2	\N
cmq0phz6i00l6hk8d8arg4ytu	cmpxvuq1d00gkhke6xmwxml94	3	B	Genel Test	2026-06-05 09:12:59.994	2026-06-05 09:12:59.994	0.2	\N
cmq0phz6i00l7hk8dvyxxt7m3	cmpxvuq1d00gkhke6xmwxml94	4	B	Genel Test	2026-06-05 09:12:59.994	2026-06-05 09:12:59.994	0.2	\N
cmq0phz6i00l8hk8d4yy47ap1	cmpxvuq1d00gkhke6xmwxml94	5	D	Genel Test	2026-06-05 09:12:59.994	2026-06-05 09:12:59.994	0.2	\N
cmq0phz6i00l9hk8di1k791bw	cmpxvuq1d00gkhke6xmwxml94	6	D	Genel Test	2026-06-05 09:12:59.994	2026-06-05 09:12:59.994	0.2	\N
cmq0phz6i00lahk8dep3ony83	cmpxvuq1d00gkhke6xmwxml94	7	C	Genel Test	2026-06-05 09:12:59.994	2026-06-05 09:12:59.994	0.2	\N
cmq0phz6i00lbhk8df2qtzci3	cmpxvuq1d00gkhke6xmwxml94	8	C	Genel Test	2026-06-05 09:12:59.994	2026-06-05 09:12:59.994	0.2	\N
cmq0phz6i00lchk8dbiphj66s	cmpxvuq1d00gkhke6xmwxml94	9	C	Genel Test	2026-06-05 09:12:59.994	2026-06-05 09:12:59.994	0.2	\N
cmq0phz6i00ldhk8d7569joap	cmpxvuq1d00gkhke6xmwxml94	10	B	Genel Test	2026-06-05 09:12:59.994	2026-06-05 09:12:59.994	0.2	\N
cmq0phz6i00lehk8d3ir96bnu	cmpxvuq1d00gkhke6xmwxml94	11	E	Genel Test	2026-06-05 09:12:59.994	2026-06-05 09:12:59.994	0.2	\N
cmq0phz6i00lfhk8dop9zmm18	cmpxvuq1d00gkhke6xmwxml94	12	B	Genel Test	2026-06-05 09:12:59.994	2026-06-05 09:12:59.994	0.2	\N
cmq0phz6i00lghk8dwxhedhy0	cmpxvuq1d00gkhke6xmwxml94	13	A	Genel Test	2026-06-05 09:12:59.994	2026-06-05 09:12:59.994	0.2	\N
cmq0phz6i00lhhk8dk59iy76y	cmpxvuq1d00gkhke6xmwxml94	14	D	Genel Test	2026-06-05 09:12:59.994	2026-06-05 09:12:59.994	0.2	\N
cmq0phz6i00lihk8dpklor5xb	cmpxvuq1d00gkhke6xmwxml94	15	E	Genel Test	2026-06-05 09:12:59.994	2026-06-05 09:12:59.994	0.2	\N
cmq0phz6i00ljhk8d5syaz2rc	cmpxvuq1d00gkhke6xmwxml94	16	C	Genel Test	2026-06-05 09:12:59.994	2026-06-05 09:12:59.994	0.2	\N
cmq0ojjnd000fhk8dlfi7tclr	cmp46ome900s3hk44i4eqvhx8	16	B	İKTİSAT	2026-06-05 08:46:13.561	2026-06-05 08:46:13.561	0.2	\N
cmq0ojjnd000ghk8dkvjs20uw	cmp46ome900s3hk44i4eqvhx8	17	E	İKTİSAT	2026-06-05 08:46:13.561	2026-06-05 08:46:13.561	0.2	\N
cmq0ojjne000hhk8ddo0tfznn	cmp46ome900s3hk44i4eqvhx8	18	A	İKTİSAT	2026-06-05 08:46:13.561	2026-06-05 08:46:13.561	0.2	\N
cmq0ojjne000ihk8d9lyhsc9b	cmp46ome900s3hk44i4eqvhx8	19	A	İKTİSAT	2026-06-05 08:46:13.561	2026-06-05 08:46:13.561	0.2	\N
cmq0ojjne000jhk8dp3ks8fkr	cmp46ome900s3hk44i4eqvhx8	20	D	İKTİSAT	2026-06-05 08:46:13.561	2026-06-05 08:46:13.561	0.2	\N
cmq0ojjne000khk8dxsovenoo	cmp46ome900s3hk44i4eqvhx8	21	E	İKTİSAT	2026-06-05 08:46:13.561	2026-06-05 08:46:13.561	0.2	\N
cmq0ojjne000lhk8djc5cfm1f	cmp46ome900s3hk44i4eqvhx8	22	D	İKTİSAT	2026-06-05 08:46:13.561	2026-06-05 08:46:13.561	0.2	\N
cmq0ojjne000mhk8d0rev8a2c	cmp46ome900s3hk44i4eqvhx8	23	B	İKTİSAT	2026-06-05 08:46:13.561	2026-06-05 08:46:13.561	0.2	\N
cmq0ojjne000nhk8dkbvlkdoi	cmp46ome900s3hk44i4eqvhx8	24	D	İKTİSAT	2026-06-05 08:46:13.561	2026-06-05 08:46:13.561	0.2	\N
cmq0ojjne000ohk8dqu84a7zw	cmp46ome900s3hk44i4eqvhx8	25	C	İKTİSAT	2026-06-05 08:46:13.561	2026-06-05 08:46:13.561	0.2	\N
cmq0ojjne000phk8dtadvkdkl	cmp46ome900s3hk44i4eqvhx8	26	D	İKTİSAT	2026-06-05 08:46:13.561	2026-06-05 08:46:13.561	0.2	\N
cmq0ojjne000qhk8du7lkofcx	cmp46ome900s3hk44i4eqvhx8	27	C	İKTİSAT	2026-06-05 08:46:13.561	2026-06-05 08:46:13.561	0.2	\N
cmq0ojjne000rhk8dtf9rar7y	cmp46ome900s3hk44i4eqvhx8	28	B	İKTİSAT	2026-06-05 08:46:13.561	2026-06-05 08:46:13.561	0.2	\N
cmq0ojjne000shk8d0r37ir0n	cmp46ome900s3hk44i4eqvhx8	29	A	İKTİSAT	2026-06-05 08:46:13.561	2026-06-05 08:46:13.561	0.2	\N
cmq0ojjne000thk8dgtl56d2l	cmp46ome900s3hk44i4eqvhx8	30	B	İKTİSAT	2026-06-05 08:46:13.561	2026-06-05 08:46:13.561	0.2	\N
cmq0ojjne000uhk8dpdwoiywa	cmp46ome900s3hk44i4eqvhx8	31	B	İKTİSAT	2026-06-05 08:46:13.561	2026-06-05 08:46:13.561	0.2	\N
cmq0ojjne000vhk8de7hdz3uy	cmp46ome900s3hk44i4eqvhx8	32	D	İKTİSAT	2026-06-05 08:46:13.561	2026-06-05 08:46:13.561	0.2	\N
cmq0ojjne000whk8d6grggb4l	cmp46ome900s3hk44i4eqvhx8	33	D	İKTİSAT	2026-06-05 08:46:13.561	2026-06-05 08:46:13.561	0.2	\N
cmq0ojjne000xhk8d5546cuu9	cmp46ome900s3hk44i4eqvhx8	34	A	İKTİSAT	2026-06-05 08:46:13.561	2026-06-05 08:46:13.561	0.2	\N
cmq0ojjne000yhk8dkkgkqofu	cmp46ome900s3hk44i4eqvhx8	35	A	İKTİSAT	2026-06-05 08:46:13.561	2026-06-05 08:46:13.561	0.2	\N
cmq0ojjne000zhk8dqirvrd0i	cmp46ome900s3hk44i4eqvhx8	36	B	İKTİSAT	2026-06-05 08:46:13.561	2026-06-05 08:46:13.561	0.2	\N
cmq0ojjne0010hk8d9xqbjsl8	cmp46ome900s3hk44i4eqvhx8	37	A	İKTİSAT	2026-06-05 08:46:13.561	2026-06-05 08:46:13.561	0.2	\N
cmq0ojjne0011hk8duawevsqr	cmp46ome900s3hk44i4eqvhx8	38	E	İKTİSAT	2026-06-05 08:46:13.561	2026-06-05 08:46:13.561	0.2	\N
cmq0ojjne0012hk8dbx380xd8	cmp46ome900s3hk44i4eqvhx8	39	C	İKTİSAT	2026-06-05 08:46:13.561	2026-06-05 08:46:13.561	0.2	\N
cmq0ojjne0013hk8dtoz78eng	cmp46ome900s3hk44i4eqvhx8	40	E	İKTİSAT	2026-06-05 08:46:13.561	2026-06-05 08:46:13.561	0.2	\N
cmq0pgghq00flhk8dicrcankf	cmpxw4fdb00ldhke6mjnc94ez	2	C	Genel Yetenek 	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgghq00fmhk8dnsg73x89	cmpxw4fdb00ldhke6mjnc94ez	3	A	Genel Yetenek 	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgghq00fnhk8diuw6d6hr	cmpxw4fdb00ldhke6mjnc94ez	4	D	Genel Yetenek 	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgghq00fohk8d2o4pn77n	cmpxw4fdb00ldhke6mjnc94ez	5	B	Genel Yetenek 	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgghq00fphk8de6ehc3ry	cmpxw4fdb00ldhke6mjnc94ez	6	B	Genel Yetenek 	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgghq00fqhk8dhfm2wkcc	cmpxw4fdb00ldhke6mjnc94ez	7	A	Genel Yetenek 	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgghq00frhk8dk8xjpgb9	cmpxw4fdb00ldhke6mjnc94ez	8	D	Genel Yetenek 	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgghq00fshk8d7es46qas	cmpxw4fdb00ldhke6mjnc94ez	9	E	Genel Yetenek 	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgghq00fthk8dpp4nll4z	cmpxw4fdb00ldhke6mjnc94ez	10	B	Genel Yetenek 	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgghq00fuhk8dutp5spfo	cmpxw4fdb00ldhke6mjnc94ez	11	E	Genel Yetenek 	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgghq00fvhk8dqeme4ixx	cmpxw4fdb00ldhke6mjnc94ez	12	A	Genel Yetenek 	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgghq00fwhk8dn25c01qk	cmpxw4fdb00ldhke6mjnc94ez	13	A	Genel Yetenek 	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgghq00fxhk8d2r5u5ra6	cmpxw4fdb00ldhke6mjnc94ez	14	A	Genel Yetenek 	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgghq00fyhk8du6fgbbyc	cmpxw4fdb00ldhke6mjnc94ez	15	C	Genel Yetenek 	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgghq00fzhk8denqr3mel	cmpxw4fdb00ldhke6mjnc94ez	16	D	Genel Yetenek 	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgghq00g0hk8dntqv4v2u	cmpxw4fdb00ldhke6mjnc94ez	17	D	Genel Yetenek 	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgghq00g1hk8dhpbbfblp	cmpxw4fdb00ldhke6mjnc94ez	18	C	Genel Yetenek 	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgghq00g2hk8dra2itmo4	cmpxw4fdb00ldhke6mjnc94ez	19	E	Genel Yetenek 	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0phz6i00lkhk8d89u86d6j	cmpxvuq1d00gkhke6xmwxml94	17	D	Genel Test	2026-06-05 09:12:59.994	2026-06-05 09:12:59.994	0.2	\N
cmq0phz6i00llhk8dbl9qg6ow	cmpxvuq1d00gkhke6xmwxml94	18	C	Genel Test	2026-06-05 09:12:59.994	2026-06-05 09:12:59.994	0.2	\N
cmq0phz6i00lmhk8dgul1u8di	cmpxvuq1d00gkhke6xmwxml94	19	B	Genel Test	2026-06-05 09:12:59.994	2026-06-05 09:12:59.994	0.2	\N
cmq0phz6i00lnhk8d4mfpt0v3	cmpxvuq1d00gkhke6xmwxml94	20	B	Genel Test	2026-06-05 09:12:59.994	2026-06-05 09:12:59.994	0.2	\N
cmq0phz6i00lohk8d0xp0qnpy	cmpxvuq1d00gkhke6xmwxml94	21	D	Genel Test	2026-06-05 09:12:59.994	2026-06-05 09:12:59.994	0.2	\N
cmq0phz6i00lphk8dw6drewg9	cmpxvuq1d00gkhke6xmwxml94	22	C	Genel Test	2026-06-05 09:12:59.994	2026-06-05 09:12:59.994	0.2	\N
cmq0phz6i00lqhk8d0469ttl3	cmpxvuq1d00gkhke6xmwxml94	23	E	Genel Test	2026-06-05 09:12:59.994	2026-06-05 09:12:59.994	0.2	\N
cmq0phz6i00lrhk8dtdezg31g	cmpxvuq1d00gkhke6xmwxml94	24	C	Genel Test	2026-06-05 09:12:59.994	2026-06-05 09:12:59.994	0.2	\N
cmq0phz6i00lshk8dyt7vzpwg	cmpxvuq1d00gkhke6xmwxml94	25	B	Genel Test	2026-06-05 09:12:59.994	2026-06-05 09:12:59.994	0.2	\N
cmq0phz6i00lthk8dkf5e1ej9	cmpxvuq1d00gkhke6xmwxml94	26	C	Genel Test	2026-06-05 09:12:59.994	2026-06-05 09:12:59.994	0.2	\N
cmpzko8f200k0hk8cm726fef2	cmpwv00t600g6hkwpdimacnkh	1	C	Genel Yetenek 	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f300k1hk8cl99jd5zj	cmpwv00t600g6hkwpdimacnkh	2	A	Genel Yetenek 	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f300k2hk8cy97o8tg6	cmpwv00t600g6hkwpdimacnkh	3	D	Genel Yetenek 	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f300k3hk8chshw40qf	cmpwv00t600g6hkwpdimacnkh	4	E	Genel Yetenek 	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f300k4hk8ciqzfhjyr	cmpwv00t600g6hkwpdimacnkh	5	E	Genel Yetenek 	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f300k5hk8ccvoosgqc	cmpwv00t600g6hkwpdimacnkh	6	A	Genel Yetenek 	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f300k6hk8can1qujsi	cmpwv00t600g6hkwpdimacnkh	7	C	Genel Yetenek 	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f300k7hk8cmk0uq6sh	cmpwv00t600g6hkwpdimacnkh	8	A	Genel Yetenek 	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f300k8hk8cnaxjvgtf	cmpwv00t600g6hkwpdimacnkh	9	C	Genel Yetenek 	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f300k9hk8cpr88t3n5	cmpwv00t600g6hkwpdimacnkh	10	B	Genel Yetenek 	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f300kahk8c1bw9b8gx	cmpwv00t600g6hkwpdimacnkh	11	E	Genel Yetenek 	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f300kbhk8cx1gvmjti	cmpwv00t600g6hkwpdimacnkh	12	C	Genel Yetenek 	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmq0phz6i00luhk8dbqmcvre5	cmpxvuq1d00gkhke6xmwxml94	27	B	Genel Test	2026-06-05 09:12:59.994	2026-06-05 09:12:59.994	0.2	\N
cmq0phz6j00lvhk8dk6tzu50u	cmpxvuq1d00gkhke6xmwxml94	28	E	Genel Test	2026-06-05 09:12:59.994	2026-06-05 09:12:59.994	0.2	\N
cmq0phz6j00lwhk8dv4v3z0cb	cmpxvuq1d00gkhke6xmwxml94	29	A	Genel Test	2026-06-05 09:12:59.994	2026-06-05 09:12:59.994	0.2	\N
cmq0phz6j00lxhk8d5wvons2c	cmpxvuq1d00gkhke6xmwxml94	30	D	Genel Test	2026-06-05 09:12:59.994	2026-06-05 09:12:59.994	0.2	\N
cmq0phz6j00lyhk8dppwpgnz7	cmpxvuq1d00gkhke6xmwxml94	31	B	Genel Test	2026-06-05 09:12:59.994	2026-06-05 09:12:59.994	0.2	\N
cmq0phz6j00lzhk8dnh11bk71	cmpxvuq1d00gkhke6xmwxml94	32	C	Genel Test	2026-06-05 09:12:59.994	2026-06-05 09:12:59.994	0.2	\N
cmq0phz6j00m0hk8dlu03odie	cmpxvuq1d00gkhke6xmwxml94	33	B	Genel Test	2026-06-05 09:12:59.994	2026-06-05 09:12:59.994	0.2	\N
cmq0phz6j00m1hk8dd2jbcyl5	cmpxvuq1d00gkhke6xmwxml94	34	E	Genel Test	2026-06-05 09:12:59.994	2026-06-05 09:12:59.994	0.2	\N
cmq0phz6j00m2hk8dkqzzutsp	cmpxvuq1d00gkhke6xmwxml94	35	C	Genel Test	2026-06-05 09:12:59.994	2026-06-05 09:12:59.994	0.2	\N
cmq0phz6j00m3hk8db4bktpt1	cmpxvuq1d00gkhke6xmwxml94	36	E	Genel Test	2026-06-05 09:12:59.994	2026-06-05 09:12:59.994	0.2	\N
cmq0phz6j00m4hk8dptwpo9i7	cmpxvuq1d00gkhke6xmwxml94	37	C	Genel Test	2026-06-05 09:12:59.994	2026-06-05 09:12:59.994	0.2	\N
cmq0phz6j00m5hk8ddmfzzfyr	cmpxvuq1d00gkhke6xmwxml94	38	B	Genel Test	2026-06-05 09:12:59.994	2026-06-05 09:12:59.994	0.2	\N
cmq0phz6j00m6hk8dc84ccqft	cmpxvuq1d00gkhke6xmwxml94	39	D	Genel Test	2026-06-05 09:12:59.994	2026-06-05 09:12:59.994	0.2	\N
cmq0phz6j00m7hk8d8tvrk53v	cmpxvuq1d00gkhke6xmwxml94	40	D	Genel Test	2026-06-05 09:12:59.994	2026-06-05 09:12:59.994	0.2	\N
cmq0pifww00m8hk8djvoooxhh	cmpxvii4a00d5hke622cduye0	1	C	Genel Yetenek	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifww00m9hk8dvesyvkbi	cmpxvii4a00d5hke622cduye0	2	E	Genel Yetenek	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifww00mahk8dsg47tefd	cmpxvii4a00d5hke622cduye0	3	E	Genel Yetenek	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifww00mbhk8di6frazau	cmpxvii4a00d5hke622cduye0	4	D	Genel Yetenek	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifww00mchk8ddyyyty3f	cmpxvii4a00d5hke622cduye0	5	A	Genel Yetenek	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifww00mdhk8d0rdj1z6i	cmpxvii4a00d5hke622cduye0	6	E	Genel Yetenek	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifww00mehk8d6f7idjtx	cmpxvii4a00d5hke622cduye0	7	D	Genel Yetenek	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifww00mfhk8d8zauyzzr	cmpxvii4a00d5hke622cduye0	8	C	Genel Yetenek	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifww00mghk8do7404e6h	cmpxvii4a00d5hke622cduye0	9	D	Genel Yetenek	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifww00mhhk8d6vulje1r	cmpxvii4a00d5hke622cduye0	10	C	Genel Yetenek	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifww00mihk8dxqs9nztp	cmpxvii4a00d5hke622cduye0	11	B	Genel Yetenek	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifww00mjhk8dxjj4hbvz	cmpxvii4a00d5hke622cduye0	12	C	Genel Yetenek	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifww00mkhk8dwnc1flbk	cmpxvii4a00d5hke622cduye0	13	E	Genel Yetenek	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifww00mlhk8dojch4ncb	cmpxvii4a00d5hke622cduye0	14	D	Genel Yetenek	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifww00mmhk8dsoq2tr6e	cmpxvii4a00d5hke622cduye0	15	C	Genel Yetenek	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifww00mnhk8do687g7hv	cmpxvii4a00d5hke622cduye0	16	D	Genel Yetenek	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifww00mohk8d3vxmgh7v	cmpxvii4a00d5hke622cduye0	17	C	Genel Yetenek	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifww00mphk8d85s1lvdf	cmpxvii4a00d5hke622cduye0	18	D	Genel Yetenek	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifww00mqhk8dwcdphrac	cmpxvii4a00d5hke622cduye0	19	D	Genel Yetenek	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifww00mrhk8dimo5e4an	cmpxvii4a00d5hke622cduye0	20	C	Genel Yetenek	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifww00mshk8dstnfzf0u	cmpxvii4a00d5hke622cduye0	21	C	Genel Yetenek	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifww00mthk8dh5xevhpt	cmpxvii4a00d5hke622cduye0	22	C	Genel Yetenek	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifww00muhk8dr5os8hjm	cmpxvii4a00d5hke622cduye0	23	D	Genel Yetenek	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifww00mvhk8dk6m8r2f0	cmpxvii4a00d5hke622cduye0	24	E	Genel Yetenek	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifww00mwhk8d3m6fm00t	cmpxvii4a00d5hke622cduye0	25	C	Genel Yetenek	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifww00mxhk8duneeau4w	cmpxvii4a00d5hke622cduye0	26	B	Genel Yetenek	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pnqkc013ghk8d8srleexl	cmpwu7wz500cnhkwpbjuja1wf	21	E	Genel Test	2026-06-05 09:17:28.763	2026-06-05 09:17:28.763	0.2	\N
cmq0pnqkc013hhk8d3w95ny43	cmpwu7wz500cnhkwpbjuja1wf	22	C	Genel Test	2026-06-05 09:17:28.763	2026-06-05 09:17:28.763	0.2	\N
cmq0pnqkc013ihk8de0uvq1pt	cmpwu7wz500cnhkwpbjuja1wf	23	C	Genel Test	2026-06-05 09:17:28.763	2026-06-05 09:17:28.763	0.2	\N
cmq0pnqkc013jhk8dt1o3djcy	cmpwu7wz500cnhkwpbjuja1wf	24	E	Genel Test	2026-06-05 09:17:28.763	2026-06-05 09:17:28.763	0.2	\N
cmq0pnqkc013khk8doztdtjvo	cmpwu7wz500cnhkwpbjuja1wf	25	B	Genel Test	2026-06-05 09:17:28.763	2026-06-05 09:17:28.763	0.2	\N
cmq0pnqkc013lhk8dd52bop1j	cmpwu7wz500cnhkwpbjuja1wf	26	A	Genel Test	2026-06-05 09:17:28.763	2026-06-05 09:17:28.763	0.2	\N
cmq0pnqkc013mhk8dfdanulvs	cmpwu7wz500cnhkwpbjuja1wf	27	A	Genel Test	2026-06-05 09:17:28.763	2026-06-05 09:17:28.763	0.2	\N
cmq0pnqkc013nhk8do1jwahua	cmpwu7wz500cnhkwpbjuja1wf	28	A	Genel Test	2026-06-05 09:17:28.763	2026-06-05 09:17:28.763	0.2	\N
cmq0pnqkc013ohk8dnrgk69oh	cmpwu7wz500cnhkwpbjuja1wf	29	A	Genel Test	2026-06-05 09:17:28.763	2026-06-05 09:17:28.763	0.2	\N
cmq0pnqkc013phk8dd0qj7osb	cmpwu7wz500cnhkwpbjuja1wf	30	C	Genel Test	2026-06-05 09:17:28.763	2026-06-05 09:17:28.763	0.2	\N
cmq0pnqkc013qhk8dxayll63w	cmpwu7wz500cnhkwpbjuja1wf	31	C	Genel Test	2026-06-05 09:17:28.763	2026-06-05 09:17:28.763	0.2	\N
cmq0pnqkc013rhk8de3ac7erp	cmpwu7wz500cnhkwpbjuja1wf	32	A	Genel Test	2026-06-05 09:17:28.763	2026-06-05 09:17:28.763	0.2	\N
cmq0pnqkc013shk8d9735b4eo	cmpwu7wz500cnhkwpbjuja1wf	33	C	Genel Test	2026-06-05 09:17:28.763	2026-06-05 09:17:28.763	0.2	\N
cmq0pnqkc013thk8dcrcfus5b	cmpwu7wz500cnhkwpbjuja1wf	34	C	Genel Test	2026-06-05 09:17:28.763	2026-06-05 09:17:28.763	0.2	\N
cmq0pnqkc013uhk8d5e5nj6ka	cmpwu7wz500cnhkwpbjuja1wf	35	C	Genel Test	2026-06-05 09:17:28.763	2026-06-05 09:17:28.763	0.2	\N
cmq0pnqkd013vhk8do4tzonts	cmpwu7wz500cnhkwpbjuja1wf	36	D	Genel Test	2026-06-05 09:17:28.763	2026-06-05 09:17:28.763	0.2	\N
cmq0pnqkd013whk8db2s6lmbn	cmpwu7wz500cnhkwpbjuja1wf	37	E	Genel Test	2026-06-05 09:17:28.763	2026-06-05 09:17:28.763	0.2	\N
cmq0pnqkd013xhk8dhpy04gj0	cmpwu7wz500cnhkwpbjuja1wf	38	D	Genel Test	2026-06-05 09:17:28.763	2026-06-05 09:17:28.763	0.2	\N
cmpzko8f300kchk8cdyw3mp47	cmpwv00t600g6hkwpdimacnkh	13	A	Genel Yetenek 	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmq0pnqkd013yhk8d0b4lkkax	cmpwu7wz500cnhkwpbjuja1wf	39	E	Genel Test	2026-06-05 09:17:28.763	2026-06-05 09:17:28.763	0.2	\N
cmq0pnqkd013zhk8dv3l0ad30	cmpwu7wz500cnhkwpbjuja1wf	40	E	Genel Test	2026-06-05 09:17:28.763	2026-06-05 09:17:28.763	0.2	\N
cmq0pnyia0140hk8dgg4ls2vu	cmpwti7yo00a9hkwpb12fvmcd	1	C	Genel Test	2026-06-05 09:17:39.058	2026-06-05 09:17:39.058	0.2	\N
cmq0pnyia0141hk8db2z43zwl	cmpwti7yo00a9hkwpb12fvmcd	2	E	Genel Test	2026-06-05 09:17:39.058	2026-06-05 09:17:39.058	0.2	\N
cmq0pnyia0142hk8dycg6838p	cmpwti7yo00a9hkwpb12fvmcd	3	D	Genel Test	2026-06-05 09:17:39.058	2026-06-05 09:17:39.058	0.2	\N
cmq0pnyia0143hk8dd6irf8re	cmpwti7yo00a9hkwpb12fvmcd	4	D	Genel Test	2026-06-05 09:17:39.058	2026-06-05 09:17:39.058	0.2	\N
cmq0pnyia0144hk8d6tlxdu7l	cmpwti7yo00a9hkwpb12fvmcd	5	D	Genel Test	2026-06-05 09:17:39.058	2026-06-05 09:17:39.058	0.2	\N
cmq0pnyia0145hk8d6li9hahh	cmpwti7yo00a9hkwpb12fvmcd	6	D	Genel Test	2026-06-05 09:17:39.058	2026-06-05 09:17:39.058	0.2	\N
cmq0pnyia0146hk8dvnj8abph	cmpwti7yo00a9hkwpb12fvmcd	7	B	Genel Test	2026-06-05 09:17:39.058	2026-06-05 09:17:39.058	0.2	\N
cmq0pnyia0147hk8dy5zsql2p	cmpwti7yo00a9hkwpb12fvmcd	8	C	Genel Test	2026-06-05 09:17:39.058	2026-06-05 09:17:39.058	0.2	\N
cmq0pnyia0148hk8du91ni893	cmpwti7yo00a9hkwpb12fvmcd	9	B	Genel Test	2026-06-05 09:17:39.058	2026-06-05 09:17:39.058	0.2	\N
cmq0pnyia0149hk8d7qdmgdhh	cmpwti7yo00a9hkwpb12fvmcd	10	B	Genel Test	2026-06-05 09:17:39.058	2026-06-05 09:17:39.058	0.2	\N
cmq0pnyia014ahk8d78pr0hqc	cmpwti7yo00a9hkwpb12fvmcd	11	E	Genel Test	2026-06-05 09:17:39.058	2026-06-05 09:17:39.058	0.2	\N
cmq0pnyib014bhk8dqsgzj769	cmpwti7yo00a9hkwpb12fvmcd	12	A	Genel Test	2026-06-05 09:17:39.058	2026-06-05 09:17:39.058	0.2	\N
cmq0pnyib014chk8d22mbrmyc	cmpwti7yo00a9hkwpb12fvmcd	13	D	Genel Test	2026-06-05 09:17:39.058	2026-06-05 09:17:39.058	0.2	\N
cmpzko8f300kdhk8c94qk9b6p	cmpwv00t600g6hkwpdimacnkh	14	E	Genel Yetenek 	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f300kehk8cgc36ey7j	cmpwv00t600g6hkwpdimacnkh	15	B	Genel Yetenek 	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f300kfhk8c1ptto7lm	cmpwv00t600g6hkwpdimacnkh	16	E	Genel Yetenek 	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f300kghk8ccbgn7ogu	cmpwv00t600g6hkwpdimacnkh	17	A	Genel Yetenek 	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f300khhk8cix970gpn	cmpwv00t600g6hkwpdimacnkh	18	B	Genel Yetenek 	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f300kihk8cvfwzki7x	cmpwv00t600g6hkwpdimacnkh	19	D	Genel Yetenek 	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f300kjhk8cm38b6u80	cmpwv00t600g6hkwpdimacnkh	20	D	Genel Yetenek 	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f300kkhk8c2vecwkl0	cmpwv00t600g6hkwpdimacnkh	21	E	Genel Yetenek 	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f300klhk8c7yfev0fi	cmpwv00t600g6hkwpdimacnkh	22	C	Genel Yetenek 	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f300kmhk8c2mz494r5	cmpwv00t600g6hkwpdimacnkh	23	A	Genel Yetenek 	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f300knhk8ch51hrpva	cmpwv00t600g6hkwpdimacnkh	24	B	Genel Yetenek 	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f300kohk8c6aqiux4k	cmpwv00t600g6hkwpdimacnkh	25	D	Genel Yetenek 	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f300kphk8cuo99tyy2	cmpwv00t600g6hkwpdimacnkh	26	D	Genel Yetenek 	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f300kqhk8c7b8v42ts	cmpwv00t600g6hkwpdimacnkh	27	B	Genel Yetenek 	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f300krhk8cyszr0qms	cmpwv00t600g6hkwpdimacnkh	28	D	Genel Yetenek 	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f300kshk8cqf2ynrtw	cmpwv00t600g6hkwpdimacnkh	29	D	Genel Yetenek 	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f300kthk8c9mvmg4ww	cmpwv00t600g6hkwpdimacnkh	30	E	Genel Yetenek 	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f300kuhk8cm6lweru1	cmpwv00t600g6hkwpdimacnkh	31	A	Genel Yetenek 	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f400kvhk8cn8ajk3p7	cmpwv00t600g6hkwpdimacnkh	32	D	Genel Yetenek 	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f400kwhk8czzh42q2n	cmpwv00t600g6hkwpdimacnkh	33	E	Genel Yetenek 	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f400kxhk8clr8hevtu	cmpwv00t600g6hkwpdimacnkh	34	B	Genel Yetenek 	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f400kyhk8ccfnth9hs	cmpwv00t600g6hkwpdimacnkh	35	A	Genel Yetenek 	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f400kzhk8cofqpcw7d	cmpwv00t600g6hkwpdimacnkh	36	B	Genel Yetenek 	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f400l0hk8c1paywazg	cmpwv00t600g6hkwpdimacnkh	37	B	Genel Yetenek 	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f400l1hk8cy9fk6xq9	cmpwv00t600g6hkwpdimacnkh	38	C	Genel Yetenek 	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f400l2hk8cp83n2uqk	cmpwv00t600g6hkwpdimacnkh	39	C	Genel Yetenek 	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f400l3hk8c3h8zifza	cmpwv00t600g6hkwpdimacnkh	40	C	Genel Yetenek 	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f400l4hk8cfrddjh07	cmpwv00t600g6hkwpdimacnkh	41	C	Genel Yetenek 	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f400l5hk8clrgpy5xz	cmpwv00t600g6hkwpdimacnkh	42	B	Genel Yetenek 	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f400l6hk8cg900gb6p	cmpwv00t600g6hkwpdimacnkh	43	A	Genel Yetenek 	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f400l7hk8cwgz5sxyh	cmpwv00t600g6hkwpdimacnkh	44	D	Genel Yetenek 	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f400l8hk8ckh4hlkak	cmpwv00t600g6hkwpdimacnkh	45	A	Genel Yetenek 	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f400l9hk8c7u82d3sc	cmpwv00t600g6hkwpdimacnkh	46	B	Genel Yetenek 	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f400lahk8c9bvcacph	cmpwv00t600g6hkwpdimacnkh	47	E	Genel Yetenek 	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f400lbhk8cxxa3it05	cmpwv00t600g6hkwpdimacnkh	48	C	Genel Yetenek 	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f400lchk8c0fr3x6ue	cmpwv00t600g6hkwpdimacnkh	49	A	Genel Yetenek 	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f400ldhk8c72kwhfr7	cmpwv00t600g6hkwpdimacnkh	50	A	Genel Yetenek 	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f400lehk8cl2roql5n	cmpwv00t600g6hkwpdimacnkh	51	C	Genel Yetenek 	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f400lfhk8cmfacnk7o	cmpwv00t600g6hkwpdimacnkh	52	B	Genel Yetenek 	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f400lghk8c8zel1kki	cmpwv00t600g6hkwpdimacnkh	53	C	Genel Yetenek 	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f400lhhk8czv39btnl	cmpwv00t600g6hkwpdimacnkh	54	A	Genel Yetenek 	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f400lihk8ccrsecuvz	cmpwv00t600g6hkwpdimacnkh	55	E	Genel Yetenek 	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f400ljhk8c26t6139k	cmpwv00t600g6hkwpdimacnkh	56	B	Genel Yetenek 	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f400lkhk8c44hymz1f	cmpwv00t600g6hkwpdimacnkh	57	E	Genel Yetenek 	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f400llhk8c8luca0n1	cmpwv00t600g6hkwpdimacnkh	58	A	Genel Yetenek 	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmq0pnyib014dhk8d3w58wv1x	cmpwti7yo00a9hkwpb12fvmcd	14	D	Genel Test	2026-06-05 09:17:39.058	2026-06-05 09:17:39.058	0.2	\N
cmpzko8f400lmhk8cspzosrlh	cmpwv00t600g6hkwpdimacnkh	59	C	Genel Yetenek 	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f400lnhk8c5a0miqo5	cmpwv00t600g6hkwpdimacnkh	60	D	Genel Yetenek 	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f500lohk8cqsdsdtse	cmpwv00t600g6hkwpdimacnkh	61	E	Genel Kültür	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f500lphk8c7m47sk3z	cmpwv00t600g6hkwpdimacnkh	62	A	Genel Kültür	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f500lqhk8cusk8qkxt	cmpwv00t600g6hkwpdimacnkh	63	C	Genel Kültür	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f500lrhk8c6ud8nth6	cmpwv00t600g6hkwpdimacnkh	64	C	Genel Kültür	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f500lshk8cib05702e	cmpwv00t600g6hkwpdimacnkh	65	A	Genel Kültür	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f500lthk8c438xfrfi	cmpwv00t600g6hkwpdimacnkh	66	B	Genel Kültür	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f500luhk8czo4w42fr	cmpwv00t600g6hkwpdimacnkh	67	C	Genel Kültür	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f500lvhk8c05rg7e6c	cmpwv00t600g6hkwpdimacnkh	68	A	Genel Kültür	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f500lwhk8c5tw270wb	cmpwv00t600g6hkwpdimacnkh	69	C	Genel Kültür	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f500lxhk8cqys4fbww	cmpwv00t600g6hkwpdimacnkh	70	C	Genel Kültür	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f500lyhk8czoaec69m	cmpwv00t600g6hkwpdimacnkh	71	C	Genel Kültür	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f500lzhk8c3i5p890e	cmpwv00t600g6hkwpdimacnkh	72	D	Genel Kültür	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f500m0hk8cgupa9amj	cmpwv00t600g6hkwpdimacnkh	73	D	Genel Kültür	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f500m1hk8czi42goti	cmpwv00t600g6hkwpdimacnkh	74	B	Genel Kültür	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f500m2hk8ccx9i1yr9	cmpwv00t600g6hkwpdimacnkh	75	A	Genel Kültür	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f600m3hk8ckzifljez	cmpwv00t600g6hkwpdimacnkh	76	D	Genel Kültür	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f600m4hk8c09p0dlqe	cmpwv00t600g6hkwpdimacnkh	77	A	Genel Kültür	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f600m5hk8cmj94oyue	cmpwv00t600g6hkwpdimacnkh	78	C	Genel Kültür	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f600m6hk8cac8nk6vc	cmpwv00t600g6hkwpdimacnkh	79	E	Genel Kültür	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f600m7hk8cr8u9kjf0	cmpwv00t600g6hkwpdimacnkh	80	B	Genel Kültür	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f600m8hk8chjshbfp9	cmpwv00t600g6hkwpdimacnkh	81	C	Genel Kültür	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmq0org6i0014hk8difib057w	cmpceha6h002dhkdzrrzyzdbv	1	A	İktisat	2026-06-05 08:52:22.314	2026-06-05 08:52:22.314	0.2	\N
cmq0org6j0015hk8dfxzf9t7v	cmpceha6h002dhkdzrrzyzdbv	2	E	İktisat	2026-06-05 08:52:22.314	2026-06-05 08:52:22.314	0.2	\N
cmq0org6j0016hk8dqn9ybkd9	cmpceha6h002dhkdzrrzyzdbv	3	C	İktisat	2026-06-05 08:52:22.314	2026-06-05 08:52:22.314	0.2	\N
cmq0org6j0017hk8d1q80c9go	cmpceha6h002dhkdzrrzyzdbv	4	B	İktisat	2026-06-05 08:52:22.314	2026-06-05 08:52:22.314	0.2	\N
cmq0org6j0018hk8dhfo7p42x	cmpceha6h002dhkdzrrzyzdbv	5	C	İktisat	2026-06-05 08:52:22.314	2026-06-05 08:52:22.314	0.2	\N
cmq0org6j0019hk8dxc4b03mx	cmpceha6h002dhkdzrrzyzdbv	6	C	İktisat	2026-06-05 08:52:22.314	2026-06-05 08:52:22.314	0.2	\N
cmq0org6j001ahk8ddltf9i0o	cmpceha6h002dhkdzrrzyzdbv	7	D	İktisat	2026-06-05 08:52:22.314	2026-06-05 08:52:22.314	0.2	\N
cmq0org6j001bhk8db6fxo7mm	cmpceha6h002dhkdzrrzyzdbv	8	D	İktisat	2026-06-05 08:52:22.314	2026-06-05 08:52:22.314	0.2	\N
cmq0org6j001chk8de8czgjqs	cmpceha6h002dhkdzrrzyzdbv	9	E	İktisat	2026-06-05 08:52:22.314	2026-06-05 08:52:22.314	0.2	\N
cmq0org6j001dhk8de78itv79	cmpceha6h002dhkdzrrzyzdbv	10	E	İktisat	2026-06-05 08:52:22.314	2026-06-05 08:52:22.314	0.2	\N
cmq0org6j001ehk8d8bz4ehoi	cmpceha6h002dhkdzrrzyzdbv	11	D	İktisat	2026-06-05 08:52:22.314	2026-06-05 08:52:22.314	0.2	\N
cmq0org6j001fhk8dh55hbq80	cmpceha6h002dhkdzrrzyzdbv	12	E	İktisat	2026-06-05 08:52:22.314	2026-06-05 08:52:22.314	0.2	\N
cmq0org6j001ghk8dxsgen49n	cmpceha6h002dhkdzrrzyzdbv	13	C	İktisat	2026-06-05 08:52:22.314	2026-06-05 08:52:22.314	0.2	\N
cmq0org6j001hhk8dfpsqgzwc	cmpceha6h002dhkdzrrzyzdbv	14	A	İktisat	2026-06-05 08:52:22.314	2026-06-05 08:52:22.314	0.2	\N
cmq0org6j001ihk8dhxzfekhb	cmpceha6h002dhkdzrrzyzdbv	15	E	İktisat	2026-06-05 08:52:22.314	2026-06-05 08:52:22.314	0.2	\N
cmq0org6j001jhk8dfcfbev3k	cmpceha6h002dhkdzrrzyzdbv	16	E	İktisat	2026-06-05 08:52:22.314	2026-06-05 08:52:22.314	0.2	\N
cmq0org6j001khk8d511jgql2	cmpceha6h002dhkdzrrzyzdbv	17	C	İktisat	2026-06-05 08:52:22.314	2026-06-05 08:52:22.314	0.2	\N
cmq0org6j001lhk8demur3gbl	cmpceha6h002dhkdzrrzyzdbv	18	B	İktisat	2026-06-05 08:52:22.314	2026-06-05 08:52:22.314	0.2	\N
cmq0org6j001mhk8d2x84suyz	cmpceha6h002dhkdzrrzyzdbv	19	B	İktisat	2026-06-05 08:52:22.314	2026-06-05 08:52:22.314	0.2	\N
cmq0org6j001nhk8ddshklxjz	cmpceha6h002dhkdzrrzyzdbv	20	C	İktisat	2026-06-05 08:52:22.314	2026-06-05 08:52:22.314	0.2	\N
cmq0org6j001ohk8dt8so7iyy	cmpceha6h002dhkdzrrzyzdbv	21	C	İktisat	2026-06-05 08:52:22.314	2026-06-05 08:52:22.314	0.2	\N
cmq0org6j001phk8duwjpu9ba	cmpceha6h002dhkdzrrzyzdbv	22	D	İktisat	2026-06-05 08:52:22.314	2026-06-05 08:52:22.314	0.2	\N
cmq0org6j001qhk8d0icl5ms7	cmpceha6h002dhkdzrrzyzdbv	23	A	İktisat	2026-06-05 08:52:22.314	2026-06-05 08:52:22.314	0.2	\N
cmq0org6j001rhk8dyohjtp19	cmpceha6h002dhkdzrrzyzdbv	24	B	İktisat	2026-06-05 08:52:22.314	2026-06-05 08:52:22.314	0.2	\N
cmq0org6j001shk8d9jne9jsy	cmpceha6h002dhkdzrrzyzdbv	25	C	İktisat	2026-06-05 08:52:22.314	2026-06-05 08:52:22.314	0.2	\N
cmq0org6j001thk8dh0dgwbl9	cmpceha6h002dhkdzrrzyzdbv	26	B	İktisat	2026-06-05 08:52:22.314	2026-06-05 08:52:22.314	0.2	\N
cmq0org6j001uhk8dfk0fypgn	cmpceha6h002dhkdzrrzyzdbv	27	A	İktisat	2026-06-05 08:52:22.314	2026-06-05 08:52:22.314	0.2	\N
cmq0org6j001vhk8dqohirans	cmpceha6h002dhkdzrrzyzdbv	28	C	İktisat	2026-06-05 08:52:22.314	2026-06-05 08:52:22.314	0.2	\N
cmq0org6j001whk8d7y7ktowb	cmpceha6h002dhkdzrrzyzdbv	29	E	İktisat	2026-06-05 08:52:22.314	2026-06-05 08:52:22.314	0.2	\N
cmq0org6k001xhk8dne28hkeo	cmpceha6h002dhkdzrrzyzdbv	30	A	İktisat	2026-06-05 08:52:22.314	2026-06-05 08:52:22.314	0.2	\N
cmq0org6k001yhk8dphbdulp3	cmpceha6h002dhkdzrrzyzdbv	31	A	İktisat	2026-06-05 08:52:22.314	2026-06-05 08:52:22.314	0.2	\N
cmq0org6k001zhk8d3myeixkc	cmpceha6h002dhkdzrrzyzdbv	32	B	İktisat	2026-06-05 08:52:22.314	2026-06-05 08:52:22.314	0.2	\N
cmq0org6k0020hk8dfz1ybeg2	cmpceha6h002dhkdzrrzyzdbv	33	B	İktisat	2026-06-05 08:52:22.314	2026-06-05 08:52:22.314	0.2	\N
cmq0org6k0021hk8dws54oc6v	cmpceha6h002dhkdzrrzyzdbv	34	D	İktisat	2026-06-05 08:52:22.314	2026-06-05 08:52:22.314	0.2	\N
cmq0org6k0022hk8d5af9zj8x	cmpceha6h002dhkdzrrzyzdbv	35	B	İktisat	2026-06-05 08:52:22.314	2026-06-05 08:52:22.314	0.2	\N
cmq0org6k0023hk8da4mmjw2d	cmpceha6h002dhkdzrrzyzdbv	36	A	İktisat	2026-06-05 08:52:22.314	2026-06-05 08:52:22.314	0.2	\N
cmq0org6k0024hk8drjhap4g3	cmpceha6h002dhkdzrrzyzdbv	37	A	İktisat	2026-06-05 08:52:22.314	2026-06-05 08:52:22.314	0.2	\N
cmq0org6k0025hk8dyufhvd9f	cmpceha6h002dhkdzrrzyzdbv	38	D	İktisat	2026-06-05 08:52:22.314	2026-06-05 08:52:22.314	0.2	\N
cmq0org6k0026hk8d3nojr6zr	cmpceha6h002dhkdzrrzyzdbv	39	B	İktisat	2026-06-05 08:52:22.314	2026-06-05 08:52:22.314	0.2	\N
cmq0org6k0027hk8dpfl4q7fe	cmpceha6h002dhkdzrrzyzdbv	40	E	İktisat	2026-06-05 08:52:22.314	2026-06-05 08:52:22.314	0.2	\N
cmpzko8f600m9hk8clu3iv8gj	cmpwv00t600g6hkwpdimacnkh	82	B	Genel Kültür	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f600mahk8c49wwakfi	cmpwv00t600g6hkwpdimacnkh	83	A	Genel Kültür	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmq0pifww00myhk8d95a0d1bd	cmpxvii4a00d5hke622cduye0	27	A	Genel Yetenek	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifww00mzhk8dx3ywvq77	cmpxvii4a00d5hke622cduye0	28	D	Genel Yetenek	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifww00n0hk8dyvt5yrcp	cmpxvii4a00d5hke622cduye0	29	C	Genel Yetenek	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwx00n1hk8d1lrjrjbr	cmpxvii4a00d5hke622cduye0	30	D	Genel Yetenek	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwx00n2hk8dgihmqiwx	cmpxvii4a00d5hke622cduye0	31	E	Genel Yetenek	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwx00n3hk8div69ukbz	cmpxvii4a00d5hke622cduye0	32	B	Genel Yetenek	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwx00n4hk8d0ybvssl4	cmpxvii4a00d5hke622cduye0	33	B	Genel Yetenek	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwx00n5hk8dqmr6v8hu	cmpxvii4a00d5hke622cduye0	34	B	Genel Yetenek	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwx00n6hk8d5gs28h39	cmpxvii4a00d5hke622cduye0	35	E	Genel Yetenek	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwx00n7hk8dxh8bbttw	cmpxvii4a00d5hke622cduye0	36	D	Genel Yetenek	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwx00n8hk8dcztpiz14	cmpxvii4a00d5hke622cduye0	37	C	Genel Yetenek	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwx00n9hk8dth2ls8gx	cmpxvii4a00d5hke622cduye0	38	B	Genel Yetenek	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwx00nahk8dakzlmjqf	cmpxvii4a00d5hke622cduye0	39	A	Genel Yetenek	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwx00nbhk8dqxx7vw36	cmpxvii4a00d5hke622cduye0	40	C	Genel Yetenek	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwx00nchk8dnc0d7003	cmpxvii4a00d5hke622cduye0	41	D	Genel Yetenek	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwx00ndhk8d0lu4tac3	cmpxvii4a00d5hke622cduye0	42	C	Genel Yetenek	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwx00nehk8dojl3dgsi	cmpxvii4a00d5hke622cduye0	43	D	Genel Yetenek	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwx00nfhk8dqnwpfjsc	cmpxvii4a00d5hke622cduye0	44	C	Genel Yetenek	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwx00nghk8duhf9yktp	cmpxvii4a00d5hke622cduye0	45	E	Genel Yetenek	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwx00nhhk8dsrxs7u3s	cmpxvii4a00d5hke622cduye0	46	E	Genel Yetenek	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwx00nihk8dz3guky9s	cmpxvii4a00d5hke622cduye0	47	E	Genel Yetenek	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwx00njhk8dk8u4wu9z	cmpxvii4a00d5hke622cduye0	48	B	Genel Yetenek	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwx00nkhk8d6ercgxsp	cmpxvii4a00d5hke622cduye0	49	A	Genel Yetenek	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwx00nlhk8dany79c93	cmpxvii4a00d5hke622cduye0	50	C	Genel Yetenek	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwx00nmhk8dzmhushop	cmpxvii4a00d5hke622cduye0	51	C	Genel Yetenek	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmpzko8f700mbhk8cu52i76kj	cmpwv00t600g6hkwpdimacnkh	84	C	Genel Kültür	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f700mchk8cd8s6j8o8	cmpwv00t600g6hkwpdimacnkh	85	D	Genel Kültür	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f700mdhk8cqi6892ew	cmpwv00t600g6hkwpdimacnkh	86	A	Genel Kültür	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f700mehk8cd3iq97d6	cmpwv00t600g6hkwpdimacnkh	87	C	Genel Kültür	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f800mfhk8cjvc0ftt2	cmpwv00t600g6hkwpdimacnkh	88	C	Genel Kültür	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f800mghk8ckgdgmwed	cmpwv00t600g6hkwpdimacnkh	89	B	Genel Kültür	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f800mhhk8cw8ykmh46	cmpwv00t600g6hkwpdimacnkh	90	D	Genel Kültür	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f800mihk8cie9hr3hf	cmpwv00t600g6hkwpdimacnkh	91	D	Genel Kültür	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f800mjhk8ct2tjde9y	cmpwv00t600g6hkwpdimacnkh	92	E	Genel Kültür	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f800mkhk8c5hfa0hrk	cmpwv00t600g6hkwpdimacnkh	93	A	Genel Kültür	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f800mlhk8c0jf0khg0	cmpwv00t600g6hkwpdimacnkh	94	C	Genel Kültür	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f800mmhk8cds46obcn	cmpwv00t600g6hkwpdimacnkh	95	A	Genel Kültür	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f800mnhk8c6fh92bj3	cmpwv00t600g6hkwpdimacnkh	96	D	Genel Kültür	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f800mohk8cdo0dog4x	cmpwv00t600g6hkwpdimacnkh	97	C	Genel Kültür	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f800mphk8ckjwzggo2	cmpwv00t600g6hkwpdimacnkh	98	A	Genel Kültür	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f800mqhk8c7a02vf2g	cmpwv00t600g6hkwpdimacnkh	99	A	Genel Kültür	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f800mrhk8cimrjvv5e	cmpwv00t600g6hkwpdimacnkh	100	D	Genel Kültür	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f800mshk8cy932zrjc	cmpwv00t600g6hkwpdimacnkh	101	C	Genel Kültür	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f800mthk8co7bhjn5e	cmpwv00t600g6hkwpdimacnkh	102	C	Genel Kültür	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f800muhk8cae3pa5y2	cmpwv00t600g6hkwpdimacnkh	103	D	Genel Kültür	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f900mvhk8cdbir592n	cmpwv00t600g6hkwpdimacnkh	104	C	Genel Kültür	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f900mwhk8ch8ws4i6z	cmpwv00t600g6hkwpdimacnkh	105	A	Genel Kültür	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f900mxhk8cp77lc4qk	cmpwv00t600g6hkwpdimacnkh	106	C	Genel Kültür	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f900myhk8cfcqjc28e	cmpwv00t600g6hkwpdimacnkh	107	E	Genel Kültür	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f900mzhk8ch3j8r4ey	cmpwv00t600g6hkwpdimacnkh	108	B	Genel Kültür	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f900n0hk8c7cm9a1ro	cmpwv00t600g6hkwpdimacnkh	109	A	Genel Kültür	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f900n1hk8c50b5p9gg	cmpwv00t600g6hkwpdimacnkh	110	E	Genel Kültür	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f900n2hk8c7b9fxdgl	cmpwv00t600g6hkwpdimacnkh	111	D	Genel Kültür	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f900n3hk8cj1j181t5	cmpwv00t600g6hkwpdimacnkh	112	A	Genel Kültür	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f900n4hk8cfkvnrtsf	cmpwv00t600g6hkwpdimacnkh	113	D	Genel Kültür	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f900n5hk8cnkdxj7vz	cmpwv00t600g6hkwpdimacnkh	114	C	Genel Kültür	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f900n6hk8ckihyc4sg	cmpwv00t600g6hkwpdimacnkh	115	A	Genel Kültür	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f900n7hk8ceqaf46bx	cmpwv00t600g6hkwpdimacnkh	116	D	Genel Kültür	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f900n8hk8cqcymwvtk	cmpwv00t600g6hkwpdimacnkh	117	B	Genel Kültür	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8f900n9hk8c1kj7sa0n	cmpwv00t600g6hkwpdimacnkh	118	C	Genel Kültür	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8fa00nahk8c144dk5d0	cmpwv00t600g6hkwpdimacnkh	119	D	Genel Kültür	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmpzko8fa00nbhk8cdiomt01r	cmpwv00t600g6hkwpdimacnkh	120	B	Genel Kültür	2026-06-04 14:10:07.645	2026-06-04 14:10:07.645	0.1	\N
cmq0pnyib014ehk8dfns24ubp	cmpwti7yo00a9hkwpb12fvmcd	15	A	Genel Test	2026-06-05 09:17:39.058	2026-06-05 09:17:39.058	0.2	\N
cmq0pnyib014fhk8ds5jpnavl	cmpwti7yo00a9hkwpb12fvmcd	16	C	Genel Test	2026-06-05 09:17:39.058	2026-06-05 09:17:39.058	0.2	\N
cmq0pnyib014ghk8dkhm2xvqt	cmpwti7yo00a9hkwpb12fvmcd	17	E	Genel Test	2026-06-05 09:17:39.058	2026-06-05 09:17:39.058	0.2	\N
cmq0pnyib014hhk8dbg04fv1b	cmpwti7yo00a9hkwpb12fvmcd	18	B	Genel Test	2026-06-05 09:17:39.058	2026-06-05 09:17:39.058	0.2	\N
cmq0pnyib014ihk8dkhdinpki	cmpwti7yo00a9hkwpb12fvmcd	19	B	Genel Test	2026-06-05 09:17:39.058	2026-06-05 09:17:39.058	0.2	\N
cmq0pnyib014jhk8d5oqioyml	cmpwti7yo00a9hkwpb12fvmcd	20	E	Genel Test	2026-06-05 09:17:39.058	2026-06-05 09:17:39.058	0.2	\N
cmq0pnyib014khk8deucnwyy1	cmpwti7yo00a9hkwpb12fvmcd	21	A	Genel Test	2026-06-05 09:17:39.058	2026-06-05 09:17:39.058	0.2	\N
cmq0pnyib014lhk8dgknmhb8k	cmpwti7yo00a9hkwpb12fvmcd	22	C	Genel Test	2026-06-05 09:17:39.058	2026-06-05 09:17:39.058	0.2	\N
cmq0pnyib014mhk8dz6i4yp63	cmpwti7yo00a9hkwpb12fvmcd	23	A	Genel Test	2026-06-05 09:17:39.058	2026-06-05 09:17:39.058	0.2	\N
cmq0pnyib014nhk8dxsbtlr4b	cmpwti7yo00a9hkwpb12fvmcd	24	D	Genel Test	2026-06-05 09:17:39.058	2026-06-05 09:17:39.058	0.2	\N
cmq0pnyib014ohk8dry93zu68	cmpwti7yo00a9hkwpb12fvmcd	25	C	Genel Test	2026-06-05 09:17:39.058	2026-06-05 09:17:39.058	0.2	\N
cmq0pnyib014phk8de30i05sq	cmpwti7yo00a9hkwpb12fvmcd	26	D	Genel Test	2026-06-05 09:17:39.058	2026-06-05 09:17:39.058	0.2	\N
cmq0pnyib014qhk8drmgu0qgt	cmpwti7yo00a9hkwpb12fvmcd	27	D	Genel Test	2026-06-05 09:17:39.058	2026-06-05 09:17:39.058	0.2	\N
cmq0pnyib014rhk8d7c61xzsf	cmpwti7yo00a9hkwpb12fvmcd	28	D	Genel Test	2026-06-05 09:17:39.058	2026-06-05 09:17:39.058	0.2	\N
cmq0pnyic014shk8dhtw74lf1	cmpwti7yo00a9hkwpb12fvmcd	29	B	Genel Test	2026-06-05 09:17:39.058	2026-06-05 09:17:39.058	0.2	\N
cmq0pnyic014thk8dthcu3erx	cmpwti7yo00a9hkwpb12fvmcd	30	D	Genel Test	2026-06-05 09:17:39.058	2026-06-05 09:17:39.058	0.2	\N
cmq0pnyic014uhk8dd3ffulhj	cmpwti7yo00a9hkwpb12fvmcd	31	D	Genel Test	2026-06-05 09:17:39.058	2026-06-05 09:17:39.058	0.2	\N
cmq0pnyic014vhk8d1m5j9sqm	cmpwti7yo00a9hkwpb12fvmcd	32	A	Genel Test	2026-06-05 09:17:39.058	2026-06-05 09:17:39.058	0.2	\N
cmq0pnyic014whk8d28udx3s0	cmpwti7yo00a9hkwpb12fvmcd	33	C	Genel Test	2026-06-05 09:17:39.058	2026-06-05 09:17:39.058	0.2	\N
cmq0pnyic014xhk8dvjrdpyfh	cmpwti7yo00a9hkwpb12fvmcd	34	E	Genel Test	2026-06-05 09:17:39.058	2026-06-05 09:17:39.058	0.2	\N
cmq0pnyic014yhk8dsp5c2zg2	cmpwti7yo00a9hkwpb12fvmcd	35	B	Genel Test	2026-06-05 09:17:39.058	2026-06-05 09:17:39.058	0.2	\N
cmq0pnyic014zhk8ds6w7mlfh	cmpwti7yo00a9hkwpb12fvmcd	36	D	Genel Test	2026-06-05 09:17:39.058	2026-06-05 09:17:39.058	0.2	\N
cmq0pnyic0150hk8do9t53lj0	cmpwti7yo00a9hkwpb12fvmcd	37	C	Genel Test	2026-06-05 09:17:39.058	2026-06-05 09:17:39.058	0.2	\N
cmq0pnyic0151hk8d19u47587	cmpwti7yo00a9hkwpb12fvmcd	38	E	Genel Test	2026-06-05 09:17:39.058	2026-06-05 09:17:39.058	0.2	\N
cmq0pnyic0152hk8dzcyjob6o	cmpwti7yo00a9hkwpb12fvmcd	39	A	Genel Test	2026-06-05 09:17:39.058	2026-06-05 09:17:39.058	0.2	\N
cmq0pnyic0153hk8dxr2dx137	cmpwti7yo00a9hkwpb12fvmcd	40	B	Genel Test	2026-06-05 09:17:39.058	2026-06-05 09:17:39.058	0.2	\N
cmq0posio0154hk8dl83vnrxr	cmpcnbiae017jhkdzjao1489e	1	C	Genel Test	2026-06-05 09:18:17.952	2026-06-05 09:18:17.952	0.2	\N
cmq0posip0155hk8dy7mkj3ca	cmpcnbiae017jhkdzjao1489e	2	C	Genel Test	2026-06-05 09:18:17.952	2026-06-05 09:18:17.952	0.2	\N
cmq0posip0156hk8d614ypmhg	cmpcnbiae017jhkdzjao1489e	3	B	Genel Test	2026-06-05 09:18:17.952	2026-06-05 09:18:17.952	0.2	\N
cmq0posip0157hk8d42jo16uv	cmpcnbiae017jhkdzjao1489e	4	D	Genel Test	2026-06-05 09:18:17.952	2026-06-05 09:18:17.952	0.2	\N
cmq0posip0158hk8dgkhv2zli	cmpcnbiae017jhkdzjao1489e	5	C	Genel Test	2026-06-05 09:18:17.952	2026-06-05 09:18:17.952	0.2	\N
cmq0posip0159hk8dw7j9oijk	cmpcnbiae017jhkdzjao1489e	6	D	Genel Test	2026-06-05 09:18:17.952	2026-06-05 09:18:17.952	0.2	\N
cmq0posip015ahk8d953nor5v	cmpcnbiae017jhkdzjao1489e	7	A	Genel Test	2026-06-05 09:18:17.952	2026-06-05 09:18:17.952	0.2	\N
cmq0posip015bhk8d1plcrfav	cmpcnbiae017jhkdzjao1489e	8	A	Genel Test	2026-06-05 09:18:17.952	2026-06-05 09:18:17.952	0.2	\N
cmq0posip015chk8dqpvaohj9	cmpcnbiae017jhkdzjao1489e	9	B	Genel Test	2026-06-05 09:18:17.952	2026-06-05 09:18:17.952	0.2	\N
cmq0posip015dhk8ddbcngtbq	cmpcnbiae017jhkdzjao1489e	10	B	Genel Test	2026-06-05 09:18:17.952	2026-06-05 09:18:17.952	0.2	\N
cmq0posip015ehk8dh2tggkgy	cmpcnbiae017jhkdzjao1489e	11	D	Genel Test	2026-06-05 09:18:17.952	2026-06-05 09:18:17.952	0.2	\N
cmq0posip015fhk8dwwm6rny2	cmpcnbiae017jhkdzjao1489e	12	E	Genel Test	2026-06-05 09:18:17.952	2026-06-05 09:18:17.952	0.2	\N
cmq0posip015ghk8doj2plp3m	cmpcnbiae017jhkdzjao1489e	13	E	Genel Test	2026-06-05 09:18:17.952	2026-06-05 09:18:17.952	0.2	\N
cmq0posip015hhk8dfl7ttkxm	cmpcnbiae017jhkdzjao1489e	14	D	Genel Test	2026-06-05 09:18:17.952	2026-06-05 09:18:17.952	0.2	\N
cmq0posip015ihk8de2v51969	cmpcnbiae017jhkdzjao1489e	15	A	Genel Test	2026-06-05 09:18:17.952	2026-06-05 09:18:17.952	0.2	\N
cmq0posip015jhk8da660q76m	cmpcnbiae017jhkdzjao1489e	16	B	Genel Test	2026-06-05 09:18:17.952	2026-06-05 09:18:17.952	0.2	\N
cmq0posip015khk8d8svsudpg	cmpcnbiae017jhkdzjao1489e	17	C	Genel Test	2026-06-05 09:18:17.952	2026-06-05 09:18:17.952	0.2	\N
cmq0posip015lhk8dj4mfy6pk	cmpcnbiae017jhkdzjao1489e	18	A	Genel Test	2026-06-05 09:18:17.952	2026-06-05 09:18:17.952	0.2	\N
cmq0posip015mhk8d3dgmqzju	cmpcnbiae017jhkdzjao1489e	19	B	Genel Test	2026-06-05 09:18:17.952	2026-06-05 09:18:17.952	0.2	\N
cmq0posip015nhk8d1aksj1i9	cmpcnbiae017jhkdzjao1489e	20	A	Genel Test	2026-06-05 09:18:17.952	2026-06-05 09:18:17.952	0.2	\N
cmq0posip015ohk8d58fowl0i	cmpcnbiae017jhkdzjao1489e	21	C	Genel Test	2026-06-05 09:18:17.952	2026-06-05 09:18:17.952	0.2	\N
cmq0posip015phk8dgzi92agx	cmpcnbiae017jhkdzjao1489e	22	C	Genel Test	2026-06-05 09:18:17.952	2026-06-05 09:18:17.952	0.2	\N
cmq0posip015qhk8dioasfx04	cmpcnbiae017jhkdzjao1489e	23	A	Genel Test	2026-06-05 09:18:17.952	2026-06-05 09:18:17.952	0.2	\N
cmq0posip015rhk8dpw9bh28b	cmpcnbiae017jhkdzjao1489e	24	B	Genel Test	2026-06-05 09:18:17.952	2026-06-05 09:18:17.952	0.2	\N
cmq0posip015shk8do0oyf9p7	cmpcnbiae017jhkdzjao1489e	25	C	Genel Test	2026-06-05 09:18:17.952	2026-06-05 09:18:17.952	0.2	\N
cmq0posip015thk8d8oqf4qzv	cmpcnbiae017jhkdzjao1489e	26	A	Genel Test	2026-06-05 09:18:17.952	2026-06-05 09:18:17.952	0.2	\N
cmq0posip015uhk8d8w3lu0vl	cmpcnbiae017jhkdzjao1489e	27	B	Genel Test	2026-06-05 09:18:17.952	2026-06-05 09:18:17.952	0.2	\N
cmq0posip015vhk8diii9y48i	cmpcnbiae017jhkdzjao1489e	28	B	Genel Test	2026-06-05 09:18:17.952	2026-06-05 09:18:17.952	0.2	\N
cmq0posip015whk8dyfvjgelt	cmpcnbiae017jhkdzjao1489e	29	E	Genel Test	2026-06-05 09:18:17.952	2026-06-05 09:18:17.952	0.2	\N
cmq0posip015xhk8d3w3cvm4x	cmpcnbiae017jhkdzjao1489e	30	A	Genel Test	2026-06-05 09:18:17.952	2026-06-05 09:18:17.952	0.2	\N
cmq0posiq015yhk8dp9m8ofwi	cmpcnbiae017jhkdzjao1489e	31	B	Genel Test	2026-06-05 09:18:17.952	2026-06-05 09:18:17.952	0.2	\N
cmq0posiq015zhk8d18776sl5	cmpcnbiae017jhkdzjao1489e	32	E	Genel Test	2026-06-05 09:18:17.952	2026-06-05 09:18:17.952	0.2	\N
cmq0posiq0160hk8dmcqk97s7	cmpcnbiae017jhkdzjao1489e	33	C	Genel Test	2026-06-05 09:18:17.952	2026-06-05 09:18:17.952	0.2	\N
cmq0posiq0161hk8d5nhiw6wd	cmpcnbiae017jhkdzjao1489e	34	E	Genel Test	2026-06-05 09:18:17.952	2026-06-05 09:18:17.952	0.2	\N
cmq0posiq0162hk8d7vtczctn	cmpcnbiae017jhkdzjao1489e	35	B	Genel Test	2026-06-05 09:18:17.952	2026-06-05 09:18:17.952	0.2	\N
cmq0posiq0163hk8d80de0heq	cmpcnbiae017jhkdzjao1489e	36	C	Genel Test	2026-06-05 09:18:17.952	2026-06-05 09:18:17.952	0.2	\N
cmq0posiq0164hk8dohcn1nvi	cmpcnbiae017jhkdzjao1489e	37	D	Genel Test	2026-06-05 09:18:17.952	2026-06-05 09:18:17.952	0.2	\N
cmq0posiq0165hk8do6qmdbj5	cmpcnbiae017jhkdzjao1489e	38	D	Genel Test	2026-06-05 09:18:17.952	2026-06-05 09:18:17.952	0.2	\N
cmq0posiq0166hk8dk6gjj2n4	cmpcnbiae017jhkdzjao1489e	39	D	Genel Test	2026-06-05 09:18:17.952	2026-06-05 09:18:17.952	0.2	\N
cmq0posiq0167hk8d2layflwp	cmpcnbiae017jhkdzjao1489e	40	D	Genel Test	2026-06-05 09:18:17.952	2026-06-05 09:18:17.952	0.2	\N
cmq0ppvq40168hk8dv9r9gln4	cmpcj8j9c00ybhkdzctaisitd	1	D	Genel Test	2026-06-05 09:19:08.764	2026-06-05 09:19:08.764	0.2	\N
cmq0ppvq40169hk8dva4pstnp	cmpcj8j9c00ybhkdzctaisitd	2	E	Genel Test	2026-06-05 09:19:08.764	2026-06-05 09:19:08.764	0.2	\N
cmq0ppvq4016ahk8dk9o7i9ar	cmpcj8j9c00ybhkdzctaisitd	3	C	Genel Test	2026-06-05 09:19:08.764	2026-06-05 09:19:08.764	0.2	\N
cmq0ppvq4016bhk8dsbafcy0c	cmpcj8j9c00ybhkdzctaisitd	4	E	Genel Test	2026-06-05 09:19:08.764	2026-06-05 09:19:08.764	0.2	\N
cmq0ppvq4016chk8d6e680r9n	cmpcj8j9c00ybhkdzctaisitd	5	B	Genel Test	2026-06-05 09:19:08.764	2026-06-05 09:19:08.764	0.2	\N
cmq0pifwx00nnhk8d5lekmw88	cmpxvii4a00d5hke622cduye0	52	C	Genel Yetenek	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwx00nohk8d9j0bsdgg	cmpxvii4a00d5hke622cduye0	53	C	Genel Yetenek	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwx00nphk8dlb8eoir7	cmpxvii4a00d5hke622cduye0	54	B	Genel Yetenek	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwx00nqhk8d7si0653v	cmpxvii4a00d5hke622cduye0	55	D	Genel Yetenek	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwx00nrhk8dup9m99k6	cmpxvii4a00d5hke622cduye0	56	D	Genel Yetenek	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwx00nshk8da21nd5s3	cmpxvii4a00d5hke622cduye0	57	C	Genel Yetenek	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwx00nthk8dqppq8v9p	cmpxvii4a00d5hke622cduye0	58	C	Genel Yetenek	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwx00nuhk8dycrs2b5t	cmpxvii4a00d5hke622cduye0	59	A	Genel Yetenek	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwx00nvhk8d8dldgpqc	cmpxvii4a00d5hke622cduye0	60	E	Genel Yetenek	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwx00nwhk8dsaxftw18	cmpxvii4a00d5hke622cduye0	61	E	Genel Kültür	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwx00nxhk8dc5fnyn38	cmpxvii4a00d5hke622cduye0	62	B	Genel Kültür	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwx00nyhk8dwfsh9ptc	cmpxvii4a00d5hke622cduye0	63	A	Genel Kültür	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwx00nzhk8dbc3eqe0j	cmpxvii4a00d5hke622cduye0	64	E	Genel Kültür	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwx00o0hk8d27724nim	cmpxvii4a00d5hke622cduye0	65	B	Genel Kültür	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwx00o1hk8dcl65ullo	cmpxvii4a00d5hke622cduye0	66	C	Genel Kültür	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwx00o2hk8di1gkth62	cmpxvii4a00d5hke622cduye0	67	E	Genel Kültür	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwx00o3hk8dwmly2uba	cmpxvii4a00d5hke622cduye0	68	D	Genel Kültür	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwx00o4hk8dvyky2j5m	cmpxvii4a00d5hke622cduye0	69	B	Genel Kültür	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwx00o5hk8duiodfdsx	cmpxvii4a00d5hke622cduye0	70	D	Genel Kültür	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwx00o6hk8drbb7wr9h	cmpxvii4a00d5hke622cduye0	71	A	Genel Kültür	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwx00o7hk8d29q1pfp1	cmpxvii4a00d5hke622cduye0	72	E	Genel Kültür	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwx00o8hk8d46o0b89i	cmpxvii4a00d5hke622cduye0	73	B	Genel Kültür	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwx00o9hk8dohyw81wc	cmpxvii4a00d5hke622cduye0	74	B	Genel Kültür	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwx00oahk8d45zmlrhq	cmpxvii4a00d5hke622cduye0	75	C	Genel Kültür	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwx00obhk8dbqwe1rcj	cmpxvii4a00d5hke622cduye0	76	E	Genel Kültür	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwx00ochk8dque9jl7t	cmpxvii4a00d5hke622cduye0	77	D	Genel Kültür	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwx00odhk8dfs8t4jrh	cmpxvii4a00d5hke622cduye0	78	D	Genel Kültür	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0oxf7c0028hk8d99e2v1sy	cmpcfd9it0089hkdz1pm9fzpp	1	D	İktisat	2026-06-05 08:57:00.984	2026-06-05 08:57:00.984	0.2	\N
cmq0oxf7c0029hk8d0mlx2fbp	cmpcfd9it0089hkdz1pm9fzpp	2	C	İktisat	2026-06-05 08:57:00.984	2026-06-05 08:57:00.984	0.2	\N
cmq0oxf7c002ahk8dkv92b6il	cmpcfd9it0089hkdz1pm9fzpp	3	D	İktisat	2026-06-05 08:57:00.984	2026-06-05 08:57:00.984	0.2	\N
cmq0oxf7c002bhk8doqxzn1b9	cmpcfd9it0089hkdz1pm9fzpp	4	C	İktisat	2026-06-05 08:57:00.984	2026-06-05 08:57:00.984	0.2	\N
cmq0oxf7c002chk8dd15w56ip	cmpcfd9it0089hkdz1pm9fzpp	5	D	İktisat	2026-06-05 08:57:00.984	2026-06-05 08:57:00.984	0.2	\N
cmq0oxf7c002dhk8d2ij64rnf	cmpcfd9it0089hkdz1pm9fzpp	6	B	İktisat	2026-06-05 08:57:00.984	2026-06-05 08:57:00.984	0.2	\N
cmq0oxf7c002ehk8dsnbf9ic7	cmpcfd9it0089hkdz1pm9fzpp	7	A	İktisat	2026-06-05 08:57:00.984	2026-06-05 08:57:00.984	0.2	\N
cmq0oxf7c002fhk8dsz10y6nn	cmpcfd9it0089hkdz1pm9fzpp	8	E	İktisat	2026-06-05 08:57:00.984	2026-06-05 08:57:00.984	0.2	\N
cmq0oxf7c002ghk8dvwv73dyz	cmpcfd9it0089hkdz1pm9fzpp	9	C	İktisat	2026-06-05 08:57:00.984	2026-06-05 08:57:00.984	0.2	\N
cmq0oxf7c002hhk8d4mbese2v	cmpcfd9it0089hkdz1pm9fzpp	10	D	İktisat	2026-06-05 08:57:00.984	2026-06-05 08:57:00.984	0.2	\N
cmq0oxf7d002ihk8dbjab65nu	cmpcfd9it0089hkdz1pm9fzpp	11	D	İktisat	2026-06-05 08:57:00.984	2026-06-05 08:57:00.984	0.2	\N
cmq0oxf7d002jhk8d9hg3qv9a	cmpcfd9it0089hkdz1pm9fzpp	12	D	İktisat	2026-06-05 08:57:00.984	2026-06-05 08:57:00.984	0.2	\N
cmq0oxf7d002khk8dsenkm9v0	cmpcfd9it0089hkdz1pm9fzpp	13	B	İktisat	2026-06-05 08:57:00.984	2026-06-05 08:57:00.984	0.2	\N
cmq0oxf7d002lhk8dlm8k5nk7	cmpcfd9it0089hkdz1pm9fzpp	14	D	İktisat	2026-06-05 08:57:00.984	2026-06-05 08:57:00.984	0.2	\N
cmq0oxf7d002mhk8dnsbsfxcz	cmpcfd9it0089hkdz1pm9fzpp	15	E	İktisat	2026-06-05 08:57:00.984	2026-06-05 08:57:00.984	0.2	\N
cmq0oxf7d002nhk8d0xvd7y71	cmpcfd9it0089hkdz1pm9fzpp	16	A	İktisat	2026-06-05 08:57:00.984	2026-06-05 08:57:00.984	0.2	\N
cmq0oxf7d002ohk8d0sjkwyva	cmpcfd9it0089hkdz1pm9fzpp	17	E	İktisat	2026-06-05 08:57:00.984	2026-06-05 08:57:00.984	0.2	\N
cmq0ppvq4016dhk8dhynkmpt8	cmpcj8j9c00ybhkdzctaisitd	6	E	Genel Test	2026-06-05 09:19:08.764	2026-06-05 09:19:08.764	0.2	\N
cmq0ppvq4016ehk8dn0dxghb3	cmpcj8j9c00ybhkdzctaisitd	7	E	Genel Test	2026-06-05 09:19:08.764	2026-06-05 09:19:08.764	0.2	\N
cmq0ppvq4016fhk8dy0220z03	cmpcj8j9c00ybhkdzctaisitd	8	C	Genel Test	2026-06-05 09:19:08.764	2026-06-05 09:19:08.764	0.2	\N
cmq0ppvq4016ghk8dg0c88fcw	cmpcj8j9c00ybhkdzctaisitd	9	E	Genel Test	2026-06-05 09:19:08.764	2026-06-05 09:19:08.764	0.2	\N
cmq0ppvq4016hhk8dzcqrij0p	cmpcj8j9c00ybhkdzctaisitd	10	C	Genel Test	2026-06-05 09:19:08.764	2026-06-05 09:19:08.764	0.2	\N
cmq0ppvq4016ihk8df1zc9ljm	cmpcj8j9c00ybhkdzctaisitd	11	A	Genel Test	2026-06-05 09:19:08.764	2026-06-05 09:19:08.764	0.2	\N
cmq0ppvq4016jhk8dynthewsy	cmpcj8j9c00ybhkdzctaisitd	12	A	Genel Test	2026-06-05 09:19:08.764	2026-06-05 09:19:08.764	0.2	\N
cmq0ppvq4016khk8daurl0szw	cmpcj8j9c00ybhkdzctaisitd	13	D	Genel Test	2026-06-05 09:19:08.764	2026-06-05 09:19:08.764	0.2	\N
cmq0ppvq4016lhk8dlfleho1b	cmpcj8j9c00ybhkdzctaisitd	14	A	Genel Test	2026-06-05 09:19:08.764	2026-06-05 09:19:08.764	0.2	\N
cmq0ppvq4016mhk8dwm3t1eme	cmpcj8j9c00ybhkdzctaisitd	15	E	Genel Test	2026-06-05 09:19:08.764	2026-06-05 09:19:08.764	0.2	\N
cmq0ppvq4016nhk8d3cund6jp	cmpcj8j9c00ybhkdzctaisitd	16	B	Genel Test	2026-06-05 09:19:08.764	2026-06-05 09:19:08.764	0.2	\N
cmq0ppvq4016ohk8ditgjh1li	cmpcj8j9c00ybhkdzctaisitd	17	A	Genel Test	2026-06-05 09:19:08.764	2026-06-05 09:19:08.764	0.2	\N
cmq0ppvq4016phk8drupwt52r	cmpcj8j9c00ybhkdzctaisitd	18	C	Genel Test	2026-06-05 09:19:08.764	2026-06-05 09:19:08.764	0.2	\N
cmq0ppvq5016qhk8d5thx0zwb	cmpcj8j9c00ybhkdzctaisitd	19	E	Genel Test	2026-06-05 09:19:08.764	2026-06-05 09:19:08.764	0.2	\N
cmq0ppvq5016rhk8dcmtxiboo	cmpcj8j9c00ybhkdzctaisitd	20	C	Genel Test	2026-06-05 09:19:08.764	2026-06-05 09:19:08.764	0.2	\N
cmq0ppvq5016shk8dnuvs7uu5	cmpcj8j9c00ybhkdzctaisitd	21	D	Genel Test	2026-06-05 09:19:08.764	2026-06-05 09:19:08.764	0.2	\N
cmq0ppvq5016thk8dhhw8yyqm	cmpcj8j9c00ybhkdzctaisitd	22	C	Genel Test	2026-06-05 09:19:08.764	2026-06-05 09:19:08.764	0.2	\N
cmq0ppvq5016uhk8dsjxwxqr2	cmpcj8j9c00ybhkdzctaisitd	23	B	Genel Test	2026-06-05 09:19:08.764	2026-06-05 09:19:08.764	0.2	\N
cmq0ppvq5016vhk8d1iopwnl7	cmpcj8j9c00ybhkdzctaisitd	24	D	Genel Test	2026-06-05 09:19:08.764	2026-06-05 09:19:08.764	0.2	\N
cmq0ppvq5016whk8d1py1zx9a	cmpcj8j9c00ybhkdzctaisitd	25	D	Genel Test	2026-06-05 09:19:08.764	2026-06-05 09:19:08.764	0.2	\N
cmq0ppvq5016xhk8drmw3tahs	cmpcj8j9c00ybhkdzctaisitd	26	B	Genel Test	2026-06-05 09:19:08.764	2026-06-05 09:19:08.764	0.2	\N
cmq0ppvq5016yhk8djlw34ih3	cmpcj8j9c00ybhkdzctaisitd	27	E	Genel Test	2026-06-05 09:19:08.764	2026-06-05 09:19:08.764	0.2	\N
cmq0ppvq5016zhk8damcjv8hx	cmpcj8j9c00ybhkdzctaisitd	28	C	Genel Test	2026-06-05 09:19:08.764	2026-06-05 09:19:08.764	0.2	\N
cmq0ppvq50170hk8di040mly8	cmpcj8j9c00ybhkdzctaisitd	29	B	Genel Test	2026-06-05 09:19:08.764	2026-06-05 09:19:08.764	0.2	\N
cmq0ppvq50171hk8d89wf6tbs	cmpcj8j9c00ybhkdzctaisitd	30	C	Genel Test	2026-06-05 09:19:08.764	2026-06-05 09:19:08.764	0.2	\N
cmq0ppvq50172hk8dd5vu9ef5	cmpcj8j9c00ybhkdzctaisitd	31	D	Genel Test	2026-06-05 09:19:08.764	2026-06-05 09:19:08.764	0.2	\N
cmq0ppvq50173hk8d7z28qc00	cmpcj8j9c00ybhkdzctaisitd	32	D	Genel Test	2026-06-05 09:19:08.764	2026-06-05 09:19:08.764	0.2	\N
cmq0ppvq50174hk8ddxybiy4b	cmpcj8j9c00ybhkdzctaisitd	33	A	Genel Test	2026-06-05 09:19:08.764	2026-06-05 09:19:08.764	0.2	\N
cmq0ppvq50175hk8d6nxo6jy5	cmpcj8j9c00ybhkdzctaisitd	34	D	Genel Test	2026-06-05 09:19:08.764	2026-06-05 09:19:08.764	0.2	\N
cmq0ppvq50176hk8dndo7ztxu	cmpcj8j9c00ybhkdzctaisitd	35	B	Genel Test	2026-06-05 09:19:08.764	2026-06-05 09:19:08.764	0.2	\N
cmq0ppvq50177hk8dxtrkhn6j	cmpcj8j9c00ybhkdzctaisitd	36	A	Genel Test	2026-06-05 09:19:08.764	2026-06-05 09:19:08.764	0.2	\N
cmq0ppvq50178hk8de2x8saxe	cmpcj8j9c00ybhkdzctaisitd	37	A	Genel Test	2026-06-05 09:19:08.764	2026-06-05 09:19:08.764	0.2	\N
cmq0ppvq50179hk8dytcaocxw	cmpcj8j9c00ybhkdzctaisitd	38	A	Genel Test	2026-06-05 09:19:08.764	2026-06-05 09:19:08.764	0.2	\N
cmq0ppvq5017ahk8dgxlgrlea	cmpcj8j9c00ybhkdzctaisitd	39	C	Genel Test	2026-06-05 09:19:08.764	2026-06-05 09:19:08.764	0.2	\N
cmq0ppvq5017bhk8df6i0evua	cmpcj8j9c00ybhkdzctaisitd	40	E	Genel Test	2026-06-05 09:19:08.764	2026-06-05 09:19:08.764	0.2	\N
cmq0oxf7d002phk8dmp6b0g86	cmpcfd9it0089hkdz1pm9fzpp	18	B	İktisat	2026-06-05 08:57:00.984	2026-06-05 08:57:00.984	0.2	\N
cmq0oxf7d002qhk8dwdse9fza	cmpcfd9it0089hkdz1pm9fzpp	19	D	İktisat	2026-06-05 08:57:00.984	2026-06-05 08:57:00.984	0.2	\N
cmq0oxf7d002rhk8dpoce981k	cmpcfd9it0089hkdz1pm9fzpp	20	B	İktisat	2026-06-05 08:57:00.984	2026-06-05 08:57:00.984	0.2	\N
cmq0pifwx00oehk8d2f7bhpv0	cmpxvii4a00d5hke622cduye0	79	D	Genel Kültür	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwx00ofhk8dusj3vyxb	cmpxvii4a00d5hke622cduye0	80	B	Genel Kültür	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwx00oghk8doddmwwo7	cmpxvii4a00d5hke622cduye0	81	D	Genel Kültür	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pql1q017chk8d6237hk5j	cmpcn4fom0158hkdzn2o5idv8	1	B	Genel Test	2026-06-05 09:19:41.582	2026-06-05 09:19:41.582	0.2	\N
cmq0oxf7d002shk8dtvilqc0l	cmpcfd9it0089hkdz1pm9fzpp	21	D	İktisat	2026-06-05 08:57:00.984	2026-06-05 08:57:00.984	0.2	\N
cmq0oxf7d002thk8d17wv47b1	cmpcfd9it0089hkdz1pm9fzpp	22	D	İktisat	2026-06-05 08:57:00.984	2026-06-05 08:57:00.984	0.2	\N
cmq0oxf7d002uhk8dj2hxpxb2	cmpcfd9it0089hkdz1pm9fzpp	23	E	İktisat	2026-06-05 08:57:00.984	2026-06-05 08:57:00.984	0.2	\N
cmq0oxf7d002vhk8d339nvley	cmpcfd9it0089hkdz1pm9fzpp	24	C	İktisat	2026-06-05 08:57:00.984	2026-06-05 08:57:00.984	0.2	\N
cmq0pql1q017dhk8dffa837xp	cmpcn4fom0158hkdzn2o5idv8	2	A	Genel Test	2026-06-05 09:19:41.582	2026-06-05 09:19:41.582	0.2	\N
cmq0pql1q017ehk8dynxx07qd	cmpcn4fom0158hkdzn2o5idv8	3	C	Genel Test	2026-06-05 09:19:41.582	2026-06-05 09:19:41.582	0.2	\N
cmq0pql1q017fhk8dkxtdzx3p	cmpcn4fom0158hkdzn2o5idv8	4	C	Genel Test	2026-06-05 09:19:41.582	2026-06-05 09:19:41.582	0.2	\N
cmq0pql1q017ghk8dfrloq8gh	cmpcn4fom0158hkdzn2o5idv8	5	E	Genel Test	2026-06-05 09:19:41.582	2026-06-05 09:19:41.582	0.2	\N
cmq0pql1q017hhk8dxwfmszk6	cmpcn4fom0158hkdzn2o5idv8	6	A	Genel Test	2026-06-05 09:19:41.582	2026-06-05 09:19:41.582	0.2	\N
cmq0pql1q017ihk8dd0pc514f	cmpcn4fom0158hkdzn2o5idv8	7	A	Genel Test	2026-06-05 09:19:41.582	2026-06-05 09:19:41.582	0.2	\N
cmq0pql1q017jhk8dx6ykue76	cmpcn4fom0158hkdzn2o5idv8	8	A	Genel Test	2026-06-05 09:19:41.582	2026-06-05 09:19:41.582	0.2	\N
cmq0pql1q017khk8d2g9o4l8k	cmpcn4fom0158hkdzn2o5idv8	9	C	Genel Test	2026-06-05 09:19:41.582	2026-06-05 09:19:41.582	0.2	\N
cmq0pql1q017lhk8dq90lu7iq	cmpcn4fom0158hkdzn2o5idv8	10	A	Genel Test	2026-06-05 09:19:41.582	2026-06-05 09:19:41.582	0.2	\N
cmq0pql1q017mhk8daneg5q65	cmpcn4fom0158hkdzn2o5idv8	11	D	Genel Test	2026-06-05 09:19:41.582	2026-06-05 09:19:41.582	0.2	\N
cmq0pql1q017nhk8dk52lc8mj	cmpcn4fom0158hkdzn2o5idv8	12	D	Genel Test	2026-06-05 09:19:41.582	2026-06-05 09:19:41.582	0.2	\N
cmq0pql1r017ohk8dsd9kpu12	cmpcn4fom0158hkdzn2o5idv8	13	B	Genel Test	2026-06-05 09:19:41.582	2026-06-05 09:19:41.582	0.2	\N
cmq0pql1r017phk8dr2ak7gch	cmpcn4fom0158hkdzn2o5idv8	14	B	Genel Test	2026-06-05 09:19:41.582	2026-06-05 09:19:41.582	0.2	\N
cmq0pql1r017qhk8dg27zay7c	cmpcn4fom0158hkdzn2o5idv8	15	D	Genel Test	2026-06-05 09:19:41.582	2026-06-05 09:19:41.582	0.2	\N
cmq0pql1r017rhk8d9kycelwp	cmpcn4fom0158hkdzn2o5idv8	16	B	Genel Test	2026-06-05 09:19:41.582	2026-06-05 09:19:41.582	0.2	\N
cmq0pifwx00ohhk8djcqmezij	cmpxvii4a00d5hke622cduye0	82	C	Genel Kültür	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwx00oihk8de746wqal	cmpxvii4a00d5hke622cduye0	83	D	Genel Kültür	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwx00ojhk8d9xdoiulb	cmpxvii4a00d5hke622cduye0	84	E	Genel Kültür	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwx00okhk8dnyzfa19u	cmpxvii4a00d5hke622cduye0	85	C	Genel Kültür	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwx00olhk8d55fwh5xx	cmpxvii4a00d5hke622cduye0	86	A	Genel Kültür	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwx00omhk8dbielczly	cmpxvii4a00d5hke622cduye0	87	C	Genel Kültür	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwx00onhk8dmustx5r3	cmpxvii4a00d5hke622cduye0	88	C	Genel Kültür	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwx00oohk8dgykapnjh	cmpxvii4a00d5hke622cduye0	89	B	Genel Kültür	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwx00ophk8dxihk3w8k	cmpxvii4a00d5hke622cduye0	90	B	Genel Kültür	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwy00oqhk8dmhwe2sio	cmpxvii4a00d5hke622cduye0	91	D	Genel Kültür	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwy00orhk8dp91aebuu	cmpxvii4a00d5hke622cduye0	92	E	Genel Kültür	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwy00oshk8d8qehuy5x	cmpxvii4a00d5hke622cduye0	93	B	Genel Kültür	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwy00othk8di18k938z	cmpxvii4a00d5hke622cduye0	94	E	Genel Kültür	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwy00ouhk8dfc2wfl8h	cmpxvii4a00d5hke622cduye0	95	E	Genel Kültür	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwy00ovhk8dgg3qf3bm	cmpxvii4a00d5hke622cduye0	96	A	Genel Kültür	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwy00owhk8dzgktm5vr	cmpxvii4a00d5hke622cduye0	97	C	Genel Kültür	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwy00oxhk8d6dicjj2m	cmpxvii4a00d5hke622cduye0	98	A	Genel Kültür	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0oxf7d002whk8di731ncyc	cmpcfd9it0089hkdz1pm9fzpp	25	C	İktisat	2026-06-05 08:57:00.984	2026-06-05 08:57:00.984	0.2	\N
cmq0oxf7d002xhk8duh2ttauh	cmpcfd9it0089hkdz1pm9fzpp	26	E	İktisat	2026-06-05 08:57:00.984	2026-06-05 08:57:00.984	0.2	\N
cmq0oxf7d002yhk8dd6qxevhm	cmpcfd9it0089hkdz1pm9fzpp	27	B	İktisat	2026-06-05 08:57:00.984	2026-06-05 08:57:00.984	0.2	\N
cmq0oxf7e002zhk8dfdmaly7l	cmpcfd9it0089hkdz1pm9fzpp	28	D	İktisat	2026-06-05 08:57:00.984	2026-06-05 08:57:00.984	0.2	\N
cmq0oxf7e0030hk8dzq21knbz	cmpcfd9it0089hkdz1pm9fzpp	29	E	İktisat	2026-06-05 08:57:00.984	2026-06-05 08:57:00.984	0.2	\N
cmq0oxf7e0031hk8dn0cs885b	cmpcfd9it0089hkdz1pm9fzpp	30	E	İktisat	2026-06-05 08:57:00.984	2026-06-05 08:57:00.984	0.2	\N
cmq0oxf7e0032hk8di06muj41	cmpcfd9it0089hkdz1pm9fzpp	31	B	İktisat	2026-06-05 08:57:00.984	2026-06-05 08:57:00.984	0.2	\N
cmq0oxf7e0033hk8dmp1deze0	cmpcfd9it0089hkdz1pm9fzpp	32	E	İktisat	2026-06-05 08:57:00.984	2026-06-05 08:57:00.984	0.2	\N
cmq0oxf7e0034hk8d6njzlold	cmpcfd9it0089hkdz1pm9fzpp	33	B	İktisat	2026-06-05 08:57:00.984	2026-06-05 08:57:00.984	0.2	\N
cmq0oxf7e0035hk8dtok25lb2	cmpcfd9it0089hkdz1pm9fzpp	34	D	İktisat	2026-06-05 08:57:00.984	2026-06-05 08:57:00.984	0.2	\N
cmq0oxf7e0036hk8dlgbj5mg3	cmpcfd9it0089hkdz1pm9fzpp	35	B	İktisat	2026-06-05 08:57:00.984	2026-06-05 08:57:00.984	0.2	\N
cmq0oxf7e0037hk8diqkq6si7	cmpcfd9it0089hkdz1pm9fzpp	36	E	İktisat	2026-06-05 08:57:00.984	2026-06-05 08:57:00.984	0.2	\N
cmq0oxf7e0038hk8dxg57qtbn	cmpcfd9it0089hkdz1pm9fzpp	37	D	İktisat	2026-06-05 08:57:00.984	2026-06-05 08:57:00.984	0.2	\N
cmq0oxf7e0039hk8dfqdfxzas	cmpcfd9it0089hkdz1pm9fzpp	38	A	İktisat	2026-06-05 08:57:00.984	2026-06-05 08:57:00.984	0.2	\N
cmq0oxf7e003ahk8dtl65pvyc	cmpcfd9it0089hkdz1pm9fzpp	39	B	İktisat	2026-06-05 08:57:00.984	2026-06-05 08:57:00.984	0.2	\N
cmq0oxf7e003bhk8dj32rfx73	cmpcfd9it0089hkdz1pm9fzpp	40	A	İktisat	2026-06-05 08:57:00.984	2026-06-05 08:57:00.984	0.2	\N
cmq0pgghq00g3hk8d15qerjdz	cmpxw4fdb00ldhke6mjnc94ez	20	C	Genel Yetenek 	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgghq00g4hk8dlkgbsbko	cmpxw4fdb00ldhke6mjnc94ez	21	C	Genel Yetenek 	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgghq00g5hk8d1gs0nnqz	cmpxw4fdb00ldhke6mjnc94ez	22	D	Genel Yetenek 	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgghr00g6hk8d23mh8vdk	cmpxw4fdb00ldhke6mjnc94ez	23	A	Genel Yetenek 	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgghr00g7hk8dg6wxux3n	cmpxw4fdb00ldhke6mjnc94ez	24	D	Genel Yetenek 	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgghr00g8hk8d766c9mf4	cmpxw4fdb00ldhke6mjnc94ez	25	A	Genel Yetenek 	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pifwy00oyhk8dq3al54ln	cmpxvii4a00d5hke622cduye0	99	A	Genel Kültür	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwy00ozhk8dsvw1e1hw	cmpxvii4a00d5hke622cduye0	100	B	Genel Kültür	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwy00p0hk8d4kj492q7	cmpxvii4a00d5hke622cduye0	101	A	Genel Kültür	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwy00p1hk8d25n27rb5	cmpxvii4a00d5hke622cduye0	102	D	Genel Kültür	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwy00p2hk8dvh87v2j8	cmpxvii4a00d5hke622cduye0	103	B	Genel Kültür	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwy00p3hk8du4wk7tor	cmpxvii4a00d5hke622cduye0	104	A	Genel Kültür	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwy00p4hk8dmj6ecr1y	cmpxvii4a00d5hke622cduye0	105	D	Genel Kültür	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwy00p5hk8dy2qbt66g	cmpxvii4a00d5hke622cduye0	106	E	Genel Kültür	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwy00p6hk8djankrhum	cmpxvii4a00d5hke622cduye0	107	B	Genel Kültür	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwy00p7hk8d7ag3jzc7	cmpxvii4a00d5hke622cduye0	108	C	Genel Kültür	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwy00p8hk8d729o5s12	cmpxvii4a00d5hke622cduye0	109	B	Genel Kültür	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwy00p9hk8dorfg9fbv	cmpxvii4a00d5hke622cduye0	110	C	Genel Kültür	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwy00pahk8dbgob8ma2	cmpxvii4a00d5hke622cduye0	111	D	Genel Kültür	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwy00pbhk8d6mw156k3	cmpxvii4a00d5hke622cduye0	112	B	Genel Kültür	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwy00pchk8dkag10kam	cmpxvii4a00d5hke622cduye0	113	C	Genel Kültür	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwy00pdhk8di5atjwi8	cmpxvii4a00d5hke622cduye0	114	D	Genel Kültür	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwy00pehk8dyi51y4qv	cmpxvii4a00d5hke622cduye0	115	C	Genel Kültür	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwy00pfhk8d5r38dko1	cmpxvii4a00d5hke622cduye0	116	B	Genel Kültür	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwy00pghk8dgq0gq1qp	cmpxvii4a00d5hke622cduye0	117	D	Genel Kültür	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwy00phhk8dufsfgups	cmpxvii4a00d5hke622cduye0	118	A	Genel Kültür	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwy00pihk8dfrnt0c2k	cmpxvii4a00d5hke622cduye0	119	C	Genel Kültür	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pifwy00pjhk8d7dtt4cng	cmpxvii4a00d5hke622cduye0	120	A	Genel Kültür	2026-06-05 09:13:21.68	2026-06-05 09:13:21.68	0.1	\N
cmq0pql1r017shk8dcs5hn6cm	cmpcn4fom0158hkdzn2o5idv8	17	D	Genel Test	2026-06-05 09:19:41.582	2026-06-05 09:19:41.582	0.2	\N
cmq0pql1r017thk8djuyhy7mh	cmpcn4fom0158hkdzn2o5idv8	18	B	Genel Test	2026-06-05 09:19:41.582	2026-06-05 09:19:41.582	0.2	\N
cmq0pql1r017uhk8db0g6qzme	cmpcn4fom0158hkdzn2o5idv8	19	D	Genel Test	2026-06-05 09:19:41.582	2026-06-05 09:19:41.582	0.2	\N
cmq0pql1r017vhk8dh96tex42	cmpcn4fom0158hkdzn2o5idv8	20	C	Genel Test	2026-06-05 09:19:41.582	2026-06-05 09:19:41.582	0.2	\N
cmq0pql1r017whk8d2bnnibfa	cmpcn4fom0158hkdzn2o5idv8	21	E	Genel Test	2026-06-05 09:19:41.582	2026-06-05 09:19:41.582	0.2	\N
cmq0pql1r017xhk8dl9m6799n	cmpcn4fom0158hkdzn2o5idv8	22	B	Genel Test	2026-06-05 09:19:41.582	2026-06-05 09:19:41.582	0.2	\N
cmq0pql1r017yhk8dtvrkkyov	cmpcn4fom0158hkdzn2o5idv8	23	D	Genel Test	2026-06-05 09:19:41.582	2026-06-05 09:19:41.582	0.2	\N
cmq0pql1r017zhk8dtzgwu8zy	cmpcn4fom0158hkdzn2o5idv8	24	C	Genel Test	2026-06-05 09:19:41.582	2026-06-05 09:19:41.582	0.2	\N
cmq0pql1r0180hk8dx5xptjvy	cmpcn4fom0158hkdzn2o5idv8	25	D	Genel Test	2026-06-05 09:19:41.582	2026-06-05 09:19:41.582	0.2	\N
cmq0pql1r0181hk8dteq83us7	cmpcn4fom0158hkdzn2o5idv8	26	A	Genel Test	2026-06-05 09:19:41.582	2026-06-05 09:19:41.582	0.2	\N
cmq0pql1r0182hk8d0kwnj8dt	cmpcn4fom0158hkdzn2o5idv8	27	E	Genel Test	2026-06-05 09:19:41.582	2026-06-05 09:19:41.582	0.2	\N
cmq0pql1r0183hk8d5ckfkvix	cmpcn4fom0158hkdzn2o5idv8	28	D	Genel Test	2026-06-05 09:19:41.582	2026-06-05 09:19:41.582	0.2	\N
cmq0pql1s0184hk8dxsew5w5b	cmpcn4fom0158hkdzn2o5idv8	29	C	Genel Test	2026-06-05 09:19:41.582	2026-06-05 09:19:41.582	0.2	\N
cmq0pql1s0185hk8d5lsf27n3	cmpcn4fom0158hkdzn2o5idv8	30	A	Genel Test	2026-06-05 09:19:41.582	2026-06-05 09:19:41.582	0.2	\N
cmq0pql1s0186hk8dbobk9dn4	cmpcn4fom0158hkdzn2o5idv8	31	B	Genel Test	2026-06-05 09:19:41.582	2026-06-05 09:19:41.582	0.2	\N
cmq0pql1s0187hk8de883jhf6	cmpcn4fom0158hkdzn2o5idv8	32	E	Genel Test	2026-06-05 09:19:41.582	2026-06-05 09:19:41.582	0.2	\N
cmq0pql1s0188hk8dehp10j99	cmpcn4fom0158hkdzn2o5idv8	33	D	Genel Test	2026-06-05 09:19:41.582	2026-06-05 09:19:41.582	0.2	\N
cmq0pql1s0189hk8dxc8fr8pm	cmpcn4fom0158hkdzn2o5idv8	34	C	Genel Test	2026-06-05 09:19:41.582	2026-06-05 09:19:41.582	0.2	\N
cmq0pql1s018ahk8dygmjslba	cmpcn4fom0158hkdzn2o5idv8	35	B	Genel Test	2026-06-05 09:19:41.582	2026-06-05 09:19:41.582	0.2	\N
cmq0pql1s018bhk8dc9lau8nq	cmpcn4fom0158hkdzn2o5idv8	36	A	Genel Test	2026-06-05 09:19:41.582	2026-06-05 09:19:41.582	0.2	\N
cmq0pql1s018chk8dz4ky6ylt	cmpcn4fom0158hkdzn2o5idv8	37	C	Genel Test	2026-06-05 09:19:41.582	2026-06-05 09:19:41.582	0.2	\N
cmq0pql1s018dhk8d55l1sq1d	cmpcn4fom0158hkdzn2o5idv8	38	E	Genel Test	2026-06-05 09:19:41.582	2026-06-05 09:19:41.582	0.2	\N
cmq0pql1s018ehk8du3doq27a	cmpcn4fom0158hkdzn2o5idv8	39	A	Genel Test	2026-06-05 09:19:41.582	2026-06-05 09:19:41.582	0.2	\N
cmq0pql1s018fhk8dhmoiq4c5	cmpcn4fom0158hkdzn2o5idv8	40	A	Genel Test	2026-06-05 09:19:41.582	2026-06-05 09:19:41.582	0.2	\N
cmq0pu9j0018ghk8ddytx4qyd	cmpciwqq700w0hkdzjbgaqxol	1	C	Genel Test	2026-06-05 09:22:33.276	2026-06-05 09:22:33.276	0.2	\N
cmq0pu9j0018hhk8d6xsq6tl6	cmpciwqq700w0hkdzjbgaqxol	2	C	Genel Test	2026-06-05 09:22:33.276	2026-06-05 09:22:33.276	0.2	\N
cmq0pu9j0018ihk8dh8v5uo66	cmpciwqq700w0hkdzjbgaqxol	3	D	Genel Test	2026-06-05 09:22:33.276	2026-06-05 09:22:33.276	0.2	\N
cmq0pu9j0018jhk8dnoh6bey3	cmpciwqq700w0hkdzjbgaqxol	4	E	Genel Test	2026-06-05 09:22:33.276	2026-06-05 09:22:33.276	0.2	\N
cmq0pu9j0018khk8dqko6io0x	cmpciwqq700w0hkdzjbgaqxol	5	A	Genel Test	2026-06-05 09:22:33.276	2026-06-05 09:22:33.276	0.2	\N
cmq0pu9j0018lhk8dshpibtp4	cmpciwqq700w0hkdzjbgaqxol	6	A	Genel Test	2026-06-05 09:22:33.276	2026-06-05 09:22:33.276	0.2	\N
cmq0pu9j0018mhk8do73kvhaj	cmpciwqq700w0hkdzjbgaqxol	7	B	Genel Test	2026-06-05 09:22:33.276	2026-06-05 09:22:33.276	0.2	\N
cmq0pu9j0018nhk8df3dr614t	cmpciwqq700w0hkdzjbgaqxol	8	D	Genel Test	2026-06-05 09:22:33.276	2026-06-05 09:22:33.276	0.2	\N
cmq0pu9j0018ohk8dfx8cf3kz	cmpciwqq700w0hkdzjbgaqxol	9	D	Genel Test	2026-06-05 09:22:33.276	2026-06-05 09:22:33.276	0.2	\N
cmq0pu9j1018phk8d1tux65oc	cmpciwqq700w0hkdzjbgaqxol	10	E	Genel Test	2026-06-05 09:22:33.276	2026-06-05 09:22:33.276	0.2	\N
cmq0pu9j1018qhk8dnyc52niq	cmpciwqq700w0hkdzjbgaqxol	11	E	Genel Test	2026-06-05 09:22:33.276	2026-06-05 09:22:33.276	0.2	\N
cmq0pu9j1018rhk8d727t2mab	cmpciwqq700w0hkdzjbgaqxol	12	B	Genel Test	2026-06-05 09:22:33.276	2026-06-05 09:22:33.276	0.2	\N
cmq0pu9j1018shk8d7283g4h2	cmpciwqq700w0hkdzjbgaqxol	13	D	Genel Test	2026-06-05 09:22:33.276	2026-06-05 09:22:33.276	0.2	\N
cmq0pu9j1018thk8d8hnvdiqb	cmpciwqq700w0hkdzjbgaqxol	14	A	Genel Test	2026-06-05 09:22:33.276	2026-06-05 09:22:33.276	0.2	\N
cmq0pu9j1018uhk8da083hxmc	cmpciwqq700w0hkdzjbgaqxol	15	A	Genel Test	2026-06-05 09:22:33.276	2026-06-05 09:22:33.276	0.2	\N
cmq0pjhnv00pkhk8dogs7r5fg	cmpxvbycp00bxhke63m7149iv	1	B	Genel Test	2026-06-05 09:14:10.603	2026-06-05 09:14:10.603	0.1	\N
cmq0p6wga003chk8dff3dm75t	cmpcirzfp00tphkdz1ul5o9la	1	B	Genel Test	2026-06-05 09:04:23.242	2026-06-05 09:04:23.242	0.2	\N
cmq0p6wga003dhk8dmpq00s78	cmpcirzfp00tphkdz1ul5o9la	2	B	Genel Test	2026-06-05 09:04:23.242	2026-06-05 09:04:23.242	0.2	\N
cmq0p6wgb003ehk8di4hdpv4d	cmpcirzfp00tphkdz1ul5o9la	3	C	Genel Test	2026-06-05 09:04:23.242	2026-06-05 09:04:23.242	0.2	\N
cmq0p6wgb003fhk8dlxz1kva8	cmpcirzfp00tphkdz1ul5o9la	4	D	Genel Test	2026-06-05 09:04:23.242	2026-06-05 09:04:23.242	0.2	\N
cmq0p6wgb003ghk8dti83lbx9	cmpcirzfp00tphkdz1ul5o9la	5	C	Genel Test	2026-06-05 09:04:23.242	2026-06-05 09:04:23.242	0.2	\N
cmq0p6wgb003hhk8ds2bgi7jy	cmpcirzfp00tphkdz1ul5o9la	6	B	Genel Test	2026-06-05 09:04:23.242	2026-06-05 09:04:23.242	0.2	\N
cmq0p6wgb003ihk8dha7qcawp	cmpcirzfp00tphkdz1ul5o9la	7	A	Genel Test	2026-06-05 09:04:23.242	2026-06-05 09:04:23.242	0.2	\N
cmq0p6wgb003jhk8d637pq2qm	cmpcirzfp00tphkdz1ul5o9la	8	D	Genel Test	2026-06-05 09:04:23.242	2026-06-05 09:04:23.242	0.2	\N
cmq0p6wgb003khk8dh5bo9o7s	cmpcirzfp00tphkdz1ul5o9la	9	E	Genel Test	2026-06-05 09:04:23.242	2026-06-05 09:04:23.242	0.2	\N
cmq0p6wgb003lhk8dosrsxplp	cmpcirzfp00tphkdz1ul5o9la	10	D	Genel Test	2026-06-05 09:04:23.242	2026-06-05 09:04:23.242	0.2	\N
cmq0p6wgb003mhk8dqocg98x7	cmpcirzfp00tphkdz1ul5o9la	11	C	Genel Test	2026-06-05 09:04:23.242	2026-06-05 09:04:23.242	0.2	\N
cmq0p6wgb003nhk8dn07wrbfh	cmpcirzfp00tphkdz1ul5o9la	12	B	Genel Test	2026-06-05 09:04:23.242	2026-06-05 09:04:23.242	0.2	\N
cmq0p6wgb003ohk8d05poikuq	cmpcirzfp00tphkdz1ul5o9la	13	E	Genel Test	2026-06-05 09:04:23.242	2026-06-05 09:04:23.242	0.2	\N
cmq0p6wgb003phk8d16g26107	cmpcirzfp00tphkdz1ul5o9la	14	E	Genel Test	2026-06-05 09:04:23.242	2026-06-05 09:04:23.242	0.2	\N
cmq0p6wgb003qhk8do7oyevjl	cmpcirzfp00tphkdz1ul5o9la	15	A	Genel Test	2026-06-05 09:04:23.242	2026-06-05 09:04:23.242	0.2	\N
cmq0p6wgb003rhk8dk6581p7f	cmpcirzfp00tphkdz1ul5o9la	16	C	Genel Test	2026-06-05 09:04:23.242	2026-06-05 09:04:23.242	0.2	\N
cmq0p6wgb003shk8dqlk5hfd4	cmpcirzfp00tphkdz1ul5o9la	17	B	Genel Test	2026-06-05 09:04:23.242	2026-06-05 09:04:23.242	0.2	\N
cmq0p6wgb003thk8dm2yc9f22	cmpcirzfp00tphkdz1ul5o9la	18	D	Genel Test	2026-06-05 09:04:23.242	2026-06-05 09:04:23.242	0.2	\N
cmq0p6wgb003uhk8dclw52swx	cmpcirzfp00tphkdz1ul5o9la	19	E	Genel Test	2026-06-05 09:04:23.242	2026-06-05 09:04:23.242	0.2	\N
cmq0p6wgb003vhk8dwmh9gkdm	cmpcirzfp00tphkdz1ul5o9la	20	B	Genel Test	2026-06-05 09:04:23.242	2026-06-05 09:04:23.242	0.2	\N
cmq0p6wgb003whk8dlro5x0xv	cmpcirzfp00tphkdz1ul5o9la	21	C	Genel Test	2026-06-05 09:04:23.242	2026-06-05 09:04:23.242	0.2	\N
cmq0p6wgb003xhk8d1q3eas0y	cmpcirzfp00tphkdz1ul5o9la	22	D	Genel Test	2026-06-05 09:04:23.242	2026-06-05 09:04:23.242	0.2	\N
cmq0p6wgb003yhk8d1c720pme	cmpcirzfp00tphkdz1ul5o9la	23	A	Genel Test	2026-06-05 09:04:23.242	2026-06-05 09:04:23.242	0.2	\N
cmq0p6wgb003zhk8d8orofexz	cmpcirzfp00tphkdz1ul5o9la	24	D	Genel Test	2026-06-05 09:04:23.242	2026-06-05 09:04:23.242	0.2	\N
cmq0p6wgb0040hk8dzcqrgvld	cmpcirzfp00tphkdz1ul5o9la	25	D	Genel Test	2026-06-05 09:04:23.242	2026-06-05 09:04:23.242	0.2	\N
cmq0p6wgb0041hk8dknm6afxe	cmpcirzfp00tphkdz1ul5o9la	26	C	Genel Test	2026-06-05 09:04:23.242	2026-06-05 09:04:23.242	0.2	\N
cmq0p6wgb0042hk8dtguv4qgl	cmpcirzfp00tphkdz1ul5o9la	27	D	Genel Test	2026-06-05 09:04:23.242	2026-06-05 09:04:23.242	0.2	\N
cmq0p6wgb0043hk8do2bfbl2g	cmpcirzfp00tphkdz1ul5o9la	28	B	Genel Test	2026-06-05 09:04:23.242	2026-06-05 09:04:23.242	0.2	\N
cmq0p6wgb0044hk8dv5lqcu1h	cmpcirzfp00tphkdz1ul5o9la	29	D	Genel Test	2026-06-05 09:04:23.242	2026-06-05 09:04:23.242	0.2	\N
cmq0p6wgb0045hk8df1oznu9u	cmpcirzfp00tphkdz1ul5o9la	30	E	Genel Test	2026-06-05 09:04:23.242	2026-06-05 09:04:23.242	0.2	\N
cmq0p6wgb0046hk8dzc5im6fl	cmpcirzfp00tphkdz1ul5o9la	31	B	Genel Test	2026-06-05 09:04:23.242	2026-06-05 09:04:23.242	0.2	\N
cmq0p6wgc0047hk8depuo6j8z	cmpcirzfp00tphkdz1ul5o9la	32	A	Genel Test	2026-06-05 09:04:23.242	2026-06-05 09:04:23.242	0.2	\N
cmq0p6wgc0048hk8d0co7aa5b	cmpcirzfp00tphkdz1ul5o9la	33	D	Genel Test	2026-06-05 09:04:23.242	2026-06-05 09:04:23.242	0.2	\N
cmq0p6wgc0049hk8dipkrrnng	cmpcirzfp00tphkdz1ul5o9la	34	B	Genel Test	2026-06-05 09:04:23.242	2026-06-05 09:04:23.242	0.2	\N
cmq0p6wgc004ahk8d49gjy3qo	cmpcirzfp00tphkdz1ul5o9la	35	B	Genel Test	2026-06-05 09:04:23.242	2026-06-05 09:04:23.242	0.2	\N
cmq0p6wgc004bhk8d2a8woz00	cmpcirzfp00tphkdz1ul5o9la	36	A	Genel Test	2026-06-05 09:04:23.242	2026-06-05 09:04:23.242	0.2	\N
cmq0p6wgc004chk8diuomgi9v	cmpcirzfp00tphkdz1ul5o9la	37	A	Genel Test	2026-06-05 09:04:23.242	2026-06-05 09:04:23.242	0.2	\N
cmq0p6wgc004dhk8de23iukmu	cmpcirzfp00tphkdz1ul5o9la	38	D	Genel Test	2026-06-05 09:04:23.242	2026-06-05 09:04:23.242	0.2	\N
cmq0p6wgc004ehk8du5610ctc	cmpcirzfp00tphkdz1ul5o9la	39	E	Genel Test	2026-06-05 09:04:23.242	2026-06-05 09:04:23.242	0.2	\N
cmq0p6wgc004fhk8ddwamzxjr	cmpcirzfp00tphkdz1ul5o9la	40	B	Genel Test	2026-06-05 09:04:23.242	2026-06-05 09:04:23.242	0.2	\N
cmq0p7jpn004ghk8d930m2u3n	cmpcmzxsi012xhkdzrbj8fjy8	1	D	Genel Test	2026-06-05 09:04:53.387	2026-06-05 09:04:53.387	0.2	\N
cmq0p7jpn004hhk8degmw9bam	cmpcmzxsi012xhkdzrbj8fjy8	2	D	Genel Test	2026-06-05 09:04:53.387	2026-06-05 09:04:53.387	0.2	\N
cmq0p7jpn004ihk8dn7j6c9dn	cmpcmzxsi012xhkdzrbj8fjy8	3	E	Genel Test	2026-06-05 09:04:53.387	2026-06-05 09:04:53.387	0.2	\N
cmq0p7jpn004jhk8dm8ze60hn	cmpcmzxsi012xhkdzrbj8fjy8	4	E	Genel Test	2026-06-05 09:04:53.387	2026-06-05 09:04:53.387	0.2	\N
cmq0p7jpo004khk8dbgpu14hc	cmpcmzxsi012xhkdzrbj8fjy8	5	D	Genel Test	2026-06-05 09:04:53.387	2026-06-05 09:04:53.387	0.2	\N
cmq0p7jpo004lhk8dbdy3p4uv	cmpcmzxsi012xhkdzrbj8fjy8	6	E	Genel Test	2026-06-05 09:04:53.387	2026-06-05 09:04:53.387	0.2	\N
cmq0p7jpo004mhk8d77tbmxcg	cmpcmzxsi012xhkdzrbj8fjy8	7	A	Genel Test	2026-06-05 09:04:53.387	2026-06-05 09:04:53.387	0.2	\N
cmq0p7jpo004nhk8d6cqqqoxm	cmpcmzxsi012xhkdzrbj8fjy8	8	C	Genel Test	2026-06-05 09:04:53.387	2026-06-05 09:04:53.387	0.2	\N
cmq0p7jpo004ohk8d5khus1rb	cmpcmzxsi012xhkdzrbj8fjy8	9	C	Genel Test	2026-06-05 09:04:53.387	2026-06-05 09:04:53.387	0.2	\N
cmq0p7jpo004phk8dmfv50mxx	cmpcmzxsi012xhkdzrbj8fjy8	10	D	Genel Test	2026-06-05 09:04:53.387	2026-06-05 09:04:53.387	0.2	\N
cmq0p7jpo004qhk8dcwoq4qo8	cmpcmzxsi012xhkdzrbj8fjy8	11	E	Genel Test	2026-06-05 09:04:53.387	2026-06-05 09:04:53.387	0.2	\N
cmq0p7jpo004rhk8dirittcdw	cmpcmzxsi012xhkdzrbj8fjy8	12	D	Genel Test	2026-06-05 09:04:53.387	2026-06-05 09:04:53.387	0.2	\N
cmq0p7jpo004shk8d7qen8evw	cmpcmzxsi012xhkdzrbj8fjy8	13	C	Genel Test	2026-06-05 09:04:53.387	2026-06-05 09:04:53.387	0.2	\N
cmq0p7jpo004thk8d7x9hn81b	cmpcmzxsi012xhkdzrbj8fjy8	14	D	Genel Test	2026-06-05 09:04:53.387	2026-06-05 09:04:53.387	0.2	\N
cmq0p7jpo004uhk8droztgmh3	cmpcmzxsi012xhkdzrbj8fjy8	15	B	Genel Test	2026-06-05 09:04:53.387	2026-06-05 09:04:53.387	0.2	\N
cmq0p7jpo004vhk8davobrtz3	cmpcmzxsi012xhkdzrbj8fjy8	16	A	Genel Test	2026-06-05 09:04:53.387	2026-06-05 09:04:53.387	0.2	\N
cmq0p7jpo004whk8df9b6289q	cmpcmzxsi012xhkdzrbj8fjy8	17	E	Genel Test	2026-06-05 09:04:53.387	2026-06-05 09:04:53.387	0.2	\N
cmq0p7jpo004xhk8d3j8k71vz	cmpcmzxsi012xhkdzrbj8fjy8	18	E	Genel Test	2026-06-05 09:04:53.387	2026-06-05 09:04:53.387	0.2	\N
cmq0p7jpo004yhk8dgs60mmvs	cmpcmzxsi012xhkdzrbj8fjy8	19	A	Genel Test	2026-06-05 09:04:53.387	2026-06-05 09:04:53.387	0.2	\N
cmq0p7jpo004zhk8dgmf3gmeb	cmpcmzxsi012xhkdzrbj8fjy8	20	B	Genel Test	2026-06-05 09:04:53.387	2026-06-05 09:04:53.387	0.2	\N
cmq0p7jpo0050hk8d8a5cbg4z	cmpcmzxsi012xhkdzrbj8fjy8	21	A	Genel Test	2026-06-05 09:04:53.387	2026-06-05 09:04:53.387	0.2	\N
cmq0p7jpo0051hk8dzlhx31ke	cmpcmzxsi012xhkdzrbj8fjy8	22	D	Genel Test	2026-06-05 09:04:53.387	2026-06-05 09:04:53.387	0.2	\N
cmq0p7jpo0052hk8diea15wzg	cmpcmzxsi012xhkdzrbj8fjy8	23	E	Genel Test	2026-06-05 09:04:53.387	2026-06-05 09:04:53.387	0.2	\N
cmq0p7jpo0053hk8d1ags7h5v	cmpcmzxsi012xhkdzrbj8fjy8	24	C	Genel Test	2026-06-05 09:04:53.387	2026-06-05 09:04:53.387	0.2	\N
cmq0p7jpo0054hk8ddb9z12um	cmpcmzxsi012xhkdzrbj8fjy8	25	C	Genel Test	2026-06-05 09:04:53.387	2026-06-05 09:04:53.387	0.2	\N
cmq0p7jpo0055hk8deizmn711	cmpcmzxsi012xhkdzrbj8fjy8	26	A	Genel Test	2026-06-05 09:04:53.387	2026-06-05 09:04:53.387	0.2	\N
cmq0p7jpo0056hk8drmkvk3ri	cmpcmzxsi012xhkdzrbj8fjy8	27	E	Genel Test	2026-06-05 09:04:53.387	2026-06-05 09:04:53.387	0.2	\N
cmq0p7jpo0057hk8dpy1daww5	cmpcmzxsi012xhkdzrbj8fjy8	28	A	Genel Test	2026-06-05 09:04:53.387	2026-06-05 09:04:53.387	0.2	\N
cmq0p7jpo0058hk8d3poqf05r	cmpcmzxsi012xhkdzrbj8fjy8	29	B	Genel Test	2026-06-05 09:04:53.387	2026-06-05 09:04:53.387	0.2	\N
cmq0p7jpo0059hk8do4fnm16i	cmpcmzxsi012xhkdzrbj8fjy8	30	C	Genel Test	2026-06-05 09:04:53.387	2026-06-05 09:04:53.387	0.2	\N
cmq0p7jpo005ahk8d1srv4gma	cmpcmzxsi012xhkdzrbj8fjy8	31	C	Genel Test	2026-06-05 09:04:53.387	2026-06-05 09:04:53.387	0.2	\N
cmq0p7jpo005bhk8dkkiywxxg	cmpcmzxsi012xhkdzrbj8fjy8	32	E	Genel Test	2026-06-05 09:04:53.387	2026-06-05 09:04:53.387	0.2	\N
cmq0p7jpo005chk8dpydiagu4	cmpcmzxsi012xhkdzrbj8fjy8	33	D	Genel Test	2026-06-05 09:04:53.387	2026-06-05 09:04:53.387	0.2	\N
cmq0p7jpo005dhk8dqocr0pq3	cmpcmzxsi012xhkdzrbj8fjy8	34	C	Genel Test	2026-06-05 09:04:53.387	2026-06-05 09:04:53.387	0.2	\N
cmq0p7jpp005ehk8dz9kge6ib	cmpcmzxsi012xhkdzrbj8fjy8	35	D	Genel Test	2026-06-05 09:04:53.387	2026-06-05 09:04:53.387	0.2	\N
cmq0p7jpp005fhk8d49odyh2d	cmpcmzxsi012xhkdzrbj8fjy8	36	D	Genel Test	2026-06-05 09:04:53.387	2026-06-05 09:04:53.387	0.2	\N
cmq0p7jpp005ghk8dcvryxzxe	cmpcmzxsi012xhkdzrbj8fjy8	37	C	Genel Test	2026-06-05 09:04:53.387	2026-06-05 09:04:53.387	0.2	\N
cmq0p7jpp005hhk8dfwchkf50	cmpcmzxsi012xhkdzrbj8fjy8	38	A	Genel Test	2026-06-05 09:04:53.387	2026-06-05 09:04:53.387	0.2	\N
cmq0p7jpp005ihk8df06nle30	cmpcmzxsi012xhkdzrbj8fjy8	39	A	Genel Test	2026-06-05 09:04:53.387	2026-06-05 09:04:53.387	0.2	\N
cmq0p7jpp005jhk8d38sc0yyr	cmpcmzxsi012xhkdzrbj8fjy8	40	C	Genel Test	2026-06-05 09:04:53.387	2026-06-05 09:04:53.387	0.2	\N
cmq0pgghr00g9hk8d9wv0i65g	cmpxw4fdb00ldhke6mjnc94ez	26	C	Genel Yetenek 	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgghr00gahk8dnwrsfwoc	cmpxw4fdb00ldhke6mjnc94ez	27	C	Genel Yetenek 	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgghr00gbhk8d1023s61h	cmpxw4fdb00ldhke6mjnc94ez	28	A	Genel Yetenek 	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgghr00gchk8dtf42e2mf	cmpxw4fdb00ldhke6mjnc94ez	29	C	Genel Yetenek 	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgghr00gdhk8dfchn7k5m	cmpxw4fdb00ldhke6mjnc94ez	30	B	Genel Yetenek 	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgghr00gehk8dbp4wjuo9	cmpxw4fdb00ldhke6mjnc94ez	31	B	Genel Yetenek 	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgghr00gfhk8dyc5c4359	cmpxw4fdb00ldhke6mjnc94ez	32	C	Genel Yetenek 	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgghr00gghk8dlsoy3swt	cmpxw4fdb00ldhke6mjnc94ez	33	B	Genel Yetenek 	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgghr00ghhk8dtd2iyitr	cmpxw4fdb00ldhke6mjnc94ez	34	E	Genel Yetenek 	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgghr00gihk8dcs6rl2ow	cmpxw4fdb00ldhke6mjnc94ez	35	E	Genel Yetenek 	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgghr00gjhk8d03uiaw2o	cmpxw4fdb00ldhke6mjnc94ez	36	D	Genel Yetenek 	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgghr00gkhk8dwy8r2aq6	cmpxw4fdb00ldhke6mjnc94ez	37	A	Genel Yetenek 	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgghr00glhk8dvfofhb5n	cmpxw4fdb00ldhke6mjnc94ez	38	D	Genel Yetenek 	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgghr00gmhk8d373s6di6	cmpxw4fdb00ldhke6mjnc94ez	39	E	Genel Yetenek 	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgghr00gnhk8d6re1dwza	cmpxw4fdb00ldhke6mjnc94ez	40	E	Genel Yetenek 	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgghr00gohk8df265fs1o	cmpxw4fdb00ldhke6mjnc94ez	41	C	Genel Yetenek 	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgghr00gphk8dwuhb55br	cmpxw4fdb00ldhke6mjnc94ez	42	A	Genel Yetenek 	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgghr00gqhk8dmkuszxww	cmpxw4fdb00ldhke6mjnc94ez	43	A	Genel Yetenek 	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgghr00grhk8d372z428i	cmpxw4fdb00ldhke6mjnc94ez	44	B	Genel Yetenek 	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgghr00gshk8d90zu751l	cmpxw4fdb00ldhke6mjnc94ez	45	E	Genel Yetenek 	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgghr00gthk8dyys5wq6k	cmpxw4fdb00ldhke6mjnc94ez	46	D	Genel Yetenek 	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgghr00guhk8dcab8i2pk	cmpxw4fdb00ldhke6mjnc94ez	47	B	Genel Yetenek 	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgghr00gvhk8dhn8itegb	cmpxw4fdb00ldhke6mjnc94ez	48	B	Genel Yetenek 	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgghr00gwhk8d82bcmlxh	cmpxw4fdb00ldhke6mjnc94ez	49	B	Genel Yetenek 	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgghr00gxhk8dufomaeys	cmpxw4fdb00ldhke6mjnc94ez	50	A	Genel Yetenek 	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgghr00gyhk8d1id1fb79	cmpxw4fdb00ldhke6mjnc94ez	51	C	Genel Yetenek 	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgghr00gzhk8de6yppk4b	cmpxw4fdb00ldhke6mjnc94ez	52	B	Genel Yetenek 	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgghr00h0hk8d0fwzp70n	cmpxw4fdb00ldhke6mjnc94ez	53	C	Genel Yetenek 	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgghr00h1hk8dbyt3drqc	cmpxw4fdb00ldhke6mjnc94ez	54	E	Genel Yetenek 	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgghs00h2hk8dt26tu3ju	cmpxw4fdb00ldhke6mjnc94ez	55	A	Genel Yetenek 	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgghs00h3hk8d58e17sc6	cmpxw4fdb00ldhke6mjnc94ez	56	B	Genel Yetenek 	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgghs00h4hk8d6ihuypcg	cmpxw4fdb00ldhke6mjnc94ez	57	A	Genel Yetenek 	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgghs00h5hk8dzzu50jng	cmpxw4fdb00ldhke6mjnc94ez	58	A	Genel Yetenek 	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgghs00h6hk8dombsxs33	cmpxw4fdb00ldhke6mjnc94ez	59	B	Genel Yetenek 	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgghs00h7hk8dg7535sja	cmpxw4fdb00ldhke6mjnc94ez	60	E	Genel Yetenek 	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgghs00h8hk8dif069mbb	cmpxw4fdb00ldhke6mjnc94ez	61	A	Genel Kültür	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgghs00h9hk8d8qn7rwxs	cmpxw4fdb00ldhke6mjnc94ez	62	A	Genel Kültür	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgghs00hahk8d3xya9jna	cmpxw4fdb00ldhke6mjnc94ez	63	B	Genel Kültür	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgghs00hbhk8dab3wqn9h	cmpxw4fdb00ldhke6mjnc94ez	64	E	Genel Kültür	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgghs00hchk8dypggs9yn	cmpxw4fdb00ldhke6mjnc94ez	65	B	Genel Kültür	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0p86gg005khk8dqwdvutfc	cmpwtnr2b00bghkwp97a1ohni	1	E	Genel Test	2026-06-05 09:05:22.864	2026-06-05 09:05:22.864	0.2	\N
cmq0p86gg005lhk8djq3l7xzr	cmpwtnr2b00bghkwp97a1ohni	2	C	Genel Test	2026-06-05 09:05:22.864	2026-06-05 09:05:22.864	0.2	\N
cmq0p86gh005mhk8dt7x1j09d	cmpwtnr2b00bghkwp97a1ohni	3	B	Genel Test	2026-06-05 09:05:22.864	2026-06-05 09:05:22.864	0.2	\N
cmq0p86gh005nhk8dt30iybt9	cmpwtnr2b00bghkwp97a1ohni	4	E	Genel Test	2026-06-05 09:05:22.864	2026-06-05 09:05:22.864	0.2	\N
cmq0p86gh005ohk8d9zhoz6ub	cmpwtnr2b00bghkwp97a1ohni	5	D	Genel Test	2026-06-05 09:05:22.864	2026-06-05 09:05:22.864	0.2	\N
cmq0p86gh005phk8dtvzxawie	cmpwtnr2b00bghkwp97a1ohni	6	E	Genel Test	2026-06-05 09:05:22.864	2026-06-05 09:05:22.864	0.2	\N
cmq0p86gh005qhk8de4bci4oe	cmpwtnr2b00bghkwp97a1ohni	7	C	Genel Test	2026-06-05 09:05:22.864	2026-06-05 09:05:22.864	0.2	\N
cmq0p86gh005rhk8dqe7brygd	cmpwtnr2b00bghkwp97a1ohni	8	B	Genel Test	2026-06-05 09:05:22.864	2026-06-05 09:05:22.864	0.2	\N
cmq0p86gh005shk8d4xrybbcs	cmpwtnr2b00bghkwp97a1ohni	9	D	Genel Test	2026-06-05 09:05:22.864	2026-06-05 09:05:22.864	0.2	\N
cmq0p86gh005thk8dutpr20i2	cmpwtnr2b00bghkwp97a1ohni	10	A	Genel Test	2026-06-05 09:05:22.864	2026-06-05 09:05:22.864	0.2	\N
cmq0p86gh005uhk8dlspm2m3r	cmpwtnr2b00bghkwp97a1ohni	11	C	Genel Test	2026-06-05 09:05:22.864	2026-06-05 09:05:22.864	0.2	\N
cmq0p86gh005vhk8druk69702	cmpwtnr2b00bghkwp97a1ohni	12	C	Genel Test	2026-06-05 09:05:22.864	2026-06-05 09:05:22.864	0.2	\N
cmq0p86gh005whk8duqqdelgu	cmpwtnr2b00bghkwp97a1ohni	13	E	Genel Test	2026-06-05 09:05:22.864	2026-06-05 09:05:22.864	0.2	\N
cmq0p86gh005xhk8dxry8va1h	cmpwtnr2b00bghkwp97a1ohni	14	C	Genel Test	2026-06-05 09:05:22.864	2026-06-05 09:05:22.864	0.2	\N
cmq0p86gh005yhk8d7poudgrd	cmpwtnr2b00bghkwp97a1ohni	15	E	Genel Test	2026-06-05 09:05:22.864	2026-06-05 09:05:22.864	0.2	\N
cmq0p86gh005zhk8de72zwq2u	cmpwtnr2b00bghkwp97a1ohni	16	A	Genel Test	2026-06-05 09:05:22.864	2026-06-05 09:05:22.864	0.2	\N
cmq0p86gh0060hk8dnecu29mt	cmpwtnr2b00bghkwp97a1ohni	17	B	Genel Test	2026-06-05 09:05:22.864	2026-06-05 09:05:22.864	0.2	\N
cmq0p86gh0061hk8dfvnq9rkq	cmpwtnr2b00bghkwp97a1ohni	18	D	Genel Test	2026-06-05 09:05:22.864	2026-06-05 09:05:22.864	0.2	\N
cmq0p86gh0062hk8drzmkhqmh	cmpwtnr2b00bghkwp97a1ohni	19	C	Genel Test	2026-06-05 09:05:22.864	2026-06-05 09:05:22.864	0.2	\N
cmq0p86gh0063hk8dsof7trxz	cmpwtnr2b00bghkwp97a1ohni	20	B	Genel Test	2026-06-05 09:05:22.864	2026-06-05 09:05:22.864	0.2	\N
cmq0p86gh0064hk8dcvn3blvg	cmpwtnr2b00bghkwp97a1ohni	21	B	Genel Test	2026-06-05 09:05:22.864	2026-06-05 09:05:22.864	0.2	\N
cmq0p86gh0065hk8dtxb3v78f	cmpwtnr2b00bghkwp97a1ohni	22	C	Genel Test	2026-06-05 09:05:22.864	2026-06-05 09:05:22.864	0.2	\N
cmq0p86gh0066hk8d1al9olb1	cmpwtnr2b00bghkwp97a1ohni	23	D	Genel Test	2026-06-05 09:05:22.864	2026-06-05 09:05:22.864	0.2	\N
cmq0p86gh0067hk8dzxb6in9p	cmpwtnr2b00bghkwp97a1ohni	24	B	Genel Test	2026-06-05 09:05:22.864	2026-06-05 09:05:22.864	0.2	\N
cmq0p86gh0068hk8dxzli136m	cmpwtnr2b00bghkwp97a1ohni	25	E	Genel Test	2026-06-05 09:05:22.864	2026-06-05 09:05:22.864	0.2	\N
cmq0p86gh0069hk8dy64sahtf	cmpwtnr2b00bghkwp97a1ohni	26	D	Genel Test	2026-06-05 09:05:22.864	2026-06-05 09:05:22.864	0.2	\N
cmq0p86gh006ahk8dac3dx9o8	cmpwtnr2b00bghkwp97a1ohni	27	E	Genel Test	2026-06-05 09:05:22.864	2026-06-05 09:05:22.864	0.2	\N
cmq0p86gh006bhk8dt4er75oa	cmpwtnr2b00bghkwp97a1ohni	28	C	Genel Test	2026-06-05 09:05:22.864	2026-06-05 09:05:22.864	0.2	\N
cmq0p86gh006chk8dzdvacst5	cmpwtnr2b00bghkwp97a1ohni	29	E	Genel Test	2026-06-05 09:05:22.864	2026-06-05 09:05:22.864	0.2	\N
cmq0p86gh006dhk8d1tdomuj9	cmpwtnr2b00bghkwp97a1ohni	30	C	Genel Test	2026-06-05 09:05:22.864	2026-06-05 09:05:22.864	0.2	\N
cmq0p86gh006ehk8dpiri10ak	cmpwtnr2b00bghkwp97a1ohni	31	A	Genel Test	2026-06-05 09:05:22.864	2026-06-05 09:05:22.864	0.2	\N
cmq0p86gi006fhk8d1uul4cuc	cmpwtnr2b00bghkwp97a1ohni	32	C	Genel Test	2026-06-05 09:05:22.864	2026-06-05 09:05:22.864	0.2	\N
cmq0p86gi006ghk8d4xpwgnlh	cmpwtnr2b00bghkwp97a1ohni	33	B	Genel Test	2026-06-05 09:05:22.864	2026-06-05 09:05:22.864	0.2	\N
cmq0p86gi006hhk8ddknai5rg	cmpwtnr2b00bghkwp97a1ohni	34	E	Genel Test	2026-06-05 09:05:22.864	2026-06-05 09:05:22.864	0.2	\N
cmq0p86gi006ihk8d4zib53iv	cmpwtnr2b00bghkwp97a1ohni	35	B	Genel Test	2026-06-05 09:05:22.864	2026-06-05 09:05:22.864	0.2	\N
cmq0p86gi006jhk8d71seabys	cmpwtnr2b00bghkwp97a1ohni	36	C	Genel Test	2026-06-05 09:05:22.864	2026-06-05 09:05:22.864	0.2	\N
cmq0p86gi006khk8dsx2t0gvt	cmpwtnr2b00bghkwp97a1ohni	37	C	Genel Test	2026-06-05 09:05:22.864	2026-06-05 09:05:22.864	0.2	\N
cmq0pjhnv00plhk8dn61x6smp	cmpxvbycp00bxhke63m7149iv	2	D	Genel Test	2026-06-05 09:14:10.603	2026-06-05 09:14:10.603	0.1	\N
cmq0pjhnv00pmhk8d0hb98g3u	cmpxvbycp00bxhke63m7149iv	3	E	Genel Test	2026-06-05 09:14:10.603	2026-06-05 09:14:10.603	0.1	\N
cmq0pjhnv00pnhk8d7oxicby7	cmpxvbycp00bxhke63m7149iv	4	B	Genel Test	2026-06-05 09:14:10.603	2026-06-05 09:14:10.603	0.1	\N
cmq0pjhnv00pohk8desoxyppy	cmpxvbycp00bxhke63m7149iv	5	D	Genel Test	2026-06-05 09:14:10.603	2026-06-05 09:14:10.603	0.1	\N
cmq0pjhnv00pphk8dofg9ik20	cmpxvbycp00bxhke63m7149iv	6	C	Genel Test	2026-06-05 09:14:10.603	2026-06-05 09:14:10.603	0.1	\N
cmq0pjhnv00pqhk8d4ynp0s6d	cmpxvbycp00bxhke63m7149iv	7	D	Genel Test	2026-06-05 09:14:10.603	2026-06-05 09:14:10.603	0.1	\N
cmq0pjhnv00prhk8dckmbupb0	cmpxvbycp00bxhke63m7149iv	8	D	Genel Test	2026-06-05 09:14:10.603	2026-06-05 09:14:10.603	0.1	\N
cmq0pjhnv00pshk8d06f5mh5u	cmpxvbycp00bxhke63m7149iv	9	C	Genel Test	2026-06-05 09:14:10.603	2026-06-05 09:14:10.603	0.1	\N
cmq0pjhnv00pthk8dhu06ry6i	cmpxvbycp00bxhke63m7149iv	10	D	Genel Test	2026-06-05 09:14:10.603	2026-06-05 09:14:10.603	0.1	\N
cmq0pjhnv00puhk8d8dzmwijn	cmpxvbycp00bxhke63m7149iv	11	A	Genel Test	2026-06-05 09:14:10.603	2026-06-05 09:14:10.603	0.1	\N
cmq0pjhnv00pvhk8dwp8okltd	cmpxvbycp00bxhke63m7149iv	12	C	Genel Test	2026-06-05 09:14:10.603	2026-06-05 09:14:10.603	0.1	\N
cmq0pjhnv00pwhk8d2iioulw3	cmpxvbycp00bxhke63m7149iv	13	E	Genel Test	2026-06-05 09:14:10.603	2026-06-05 09:14:10.603	0.1	\N
cmq0pjhnv00pxhk8dcw5qhzta	cmpxvbycp00bxhke63m7149iv	14	E	Genel Test	2026-06-05 09:14:10.603	2026-06-05 09:14:10.603	0.1	\N
cmq0pjhnv00pyhk8dhaled6jb	cmpxvbycp00bxhke63m7149iv	15	A	Genel Test	2026-06-05 09:14:10.603	2026-06-05 09:14:10.603	0.1	\N
cmq0pjhnv00pzhk8dum8jgm4z	cmpxvbycp00bxhke63m7149iv	16	D	Genel Test	2026-06-05 09:14:10.603	2026-06-05 09:14:10.603	0.1	\N
cmq0pjhnv00q0hk8dgsrucf34	cmpxvbycp00bxhke63m7149iv	17	D	Genel Test	2026-06-05 09:14:10.603	2026-06-05 09:14:10.603	0.1	\N
cmq0pjhnv00q1hk8d6jezw3c2	cmpxvbycp00bxhke63m7149iv	18	D	Genel Test	2026-06-05 09:14:10.603	2026-06-05 09:14:10.603	0.1	\N
cmq0pjhnv00q2hk8df4rhp7an	cmpxvbycp00bxhke63m7149iv	19	D	Genel Test	2026-06-05 09:14:10.603	2026-06-05 09:14:10.603	0.1	\N
cmq0pjhnw00q3hk8dt1lpswid	cmpxvbycp00bxhke63m7149iv	20	C	Genel Test	2026-06-05 09:14:10.603	2026-06-05 09:14:10.603	0.1	\N
cmq0pjhnw00q4hk8dreh3f5hs	cmpxvbycp00bxhke63m7149iv	21	C	Genel Test	2026-06-05 09:14:10.603	2026-06-05 09:14:10.603	0.1	\N
cmq0pjhnw00q5hk8dm5x2bho1	cmpxvbycp00bxhke63m7149iv	22	E	Genel Test	2026-06-05 09:14:10.603	2026-06-05 09:14:10.603	0.1	\N
cmq0pjhnw00q6hk8ddil8tepf	cmpxvbycp00bxhke63m7149iv	23	D	Genel Test	2026-06-05 09:14:10.603	2026-06-05 09:14:10.603	0.1	\N
cmq0p86gi006lhk8dh9ozchxk	cmpwtnr2b00bghkwp97a1ohni	38	A	Genel Test	2026-06-05 09:05:22.864	2026-06-05 09:05:22.864	0.2	\N
cmq0p86gi006mhk8dexppcclj	cmpwtnr2b00bghkwp97a1ohni	39	A	Genel Test	2026-06-05 09:05:22.864	2026-06-05 09:05:22.864	0.2	\N
cmq0pjhnw00q7hk8dequ8dlao	cmpxvbycp00bxhke63m7149iv	24	C	Genel Test	2026-06-05 09:14:10.603	2026-06-05 09:14:10.603	0.1	\N
cmq0pjhnw00q8hk8dxuv14qe4	cmpxvbycp00bxhke63m7149iv	25	A	Genel Test	2026-06-05 09:14:10.603	2026-06-05 09:14:10.603	0.1	\N
cmq0pjhnw00q9hk8dx535efuy	cmpxvbycp00bxhke63m7149iv	26	D	Genel Test	2026-06-05 09:14:10.603	2026-06-05 09:14:10.603	0.1	\N
cmq0pjhnw00qahk8dn3k58idt	cmpxvbycp00bxhke63m7149iv	27	C	Genel Test	2026-06-05 09:14:10.603	2026-06-05 09:14:10.603	0.1	\N
cmq0pjhnw00qbhk8d11hvab8z	cmpxvbycp00bxhke63m7149iv	28	D	Genel Test	2026-06-05 09:14:10.603	2026-06-05 09:14:10.603	0.1	\N
cmq0pjhnw00qchk8d2qmjxgo9	cmpxvbycp00bxhke63m7149iv	29	B	Genel Test	2026-06-05 09:14:10.603	2026-06-05 09:14:10.603	0.1	\N
cmq0pjhnw00qdhk8dalxl3g2w	cmpxvbycp00bxhke63m7149iv	30	C	Genel Test	2026-06-05 09:14:10.603	2026-06-05 09:14:10.603	0.1	\N
cmq0pjhnw00qehk8dpxibjp26	cmpxvbycp00bxhke63m7149iv	31	E	Genel Test	2026-06-05 09:14:10.603	2026-06-05 09:14:10.603	0.1	\N
cmq0pjhnw00qfhk8dg1plan9c	cmpxvbycp00bxhke63m7149iv	32	C	Genel Test	2026-06-05 09:14:10.603	2026-06-05 09:14:10.603	0.1	\N
cmq0pjhnw00qghk8dgstpqo7z	cmpxvbycp00bxhke63m7149iv	33	E	Genel Test	2026-06-05 09:14:10.603	2026-06-05 09:14:10.603	0.1	\N
cmq0pjhnw00qhhk8db58k29sm	cmpxvbycp00bxhke63m7149iv	34	A	Genel Test	2026-06-05 09:14:10.603	2026-06-05 09:14:10.603	0.1	\N
cmq0pjhnw00qihk8dha3tcm32	cmpxvbycp00bxhke63m7149iv	35	C	Genel Test	2026-06-05 09:14:10.603	2026-06-05 09:14:10.603	0.1	\N
cmq0pjhnw00qjhk8diju7e0n2	cmpxvbycp00bxhke63m7149iv	36	B	Genel Test	2026-06-05 09:14:10.603	2026-06-05 09:14:10.603	0.1	\N
cmq0pjhnw00qkhk8d6x7k0yty	cmpxvbycp00bxhke63m7149iv	37	A	Genel Test	2026-06-05 09:14:10.603	2026-06-05 09:14:10.603	0.1	\N
cmq0pjhnw00qlhk8dufx8n19a	cmpxvbycp00bxhke63m7149iv	38	B	Genel Test	2026-06-05 09:14:10.603	2026-06-05 09:14:10.603	0.1	\N
cmq0pjhnw00qmhk8dl6rzcdv5	cmpxvbycp00bxhke63m7149iv	39	D	Genel Test	2026-06-05 09:14:10.603	2026-06-05 09:14:10.603	0.1	\N
cmq0pjhnw00qnhk8dg8p2dwo6	cmpxvbycp00bxhke63m7149iv	40	A	Genel Test	2026-06-05 09:14:10.603	2026-06-05 09:14:10.603	0.1	\N
cmq0pu9j1018vhk8dhjj3rszq	cmpciwqq700w0hkdzjbgaqxol	16	D	Genel Test	2026-06-05 09:22:33.276	2026-06-05 09:22:33.276	0.2	\N
cmq0pu9j1018whk8dupq1jtai	cmpciwqq700w0hkdzjbgaqxol	17	B	Genel Test	2026-06-05 09:22:33.276	2026-06-05 09:22:33.276	0.2	\N
cmq0pu9j1018xhk8d13i6n857	cmpciwqq700w0hkdzjbgaqxol	18	C	Genel Test	2026-06-05 09:22:33.276	2026-06-05 09:22:33.276	0.2	\N
cmq0pu9j1018yhk8ddoxvru3z	cmpciwqq700w0hkdzjbgaqxol	19	B	Genel Test	2026-06-05 09:22:33.276	2026-06-05 09:22:33.276	0.2	\N
cmq0pu9j1018zhk8ds8ubj9bb	cmpciwqq700w0hkdzjbgaqxol	20	E	Genel Test	2026-06-05 09:22:33.276	2026-06-05 09:22:33.276	0.2	\N
cmq0pu9j10190hk8dk1yhjs1z	cmpciwqq700w0hkdzjbgaqxol	21	D	Genel Test	2026-06-05 09:22:33.276	2026-06-05 09:22:33.276	0.2	\N
cmq0pu9j10191hk8dj0mnr891	cmpciwqq700w0hkdzjbgaqxol	22	C	Genel Test	2026-06-05 09:22:33.276	2026-06-05 09:22:33.276	0.2	\N
cmq0pu9j10192hk8d6xdmb15t	cmpciwqq700w0hkdzjbgaqxol	23	D	Genel Test	2026-06-05 09:22:33.276	2026-06-05 09:22:33.276	0.2	\N
cmq0pu9j10193hk8dqu0l2a6z	cmpciwqq700w0hkdzjbgaqxol	24	A	Genel Test	2026-06-05 09:22:33.276	2026-06-05 09:22:33.276	0.2	\N
cmq0pu9j10194hk8dvnri5g3r	cmpciwqq700w0hkdzjbgaqxol	25	C	Genel Test	2026-06-05 09:22:33.276	2026-06-05 09:22:33.276	0.2	\N
cmq0pu9j10195hk8dbzenku72	cmpciwqq700w0hkdzjbgaqxol	26	B	Genel Test	2026-06-05 09:22:33.276	2026-06-05 09:22:33.276	0.2	\N
cmq0pu9j10196hk8d8boo8kxz	cmpciwqq700w0hkdzjbgaqxol	27	C	Genel Test	2026-06-05 09:22:33.276	2026-06-05 09:22:33.276	0.2	\N
cmq0pu9j10197hk8dt86kjz0m	cmpciwqq700w0hkdzjbgaqxol	28	D	Genel Test	2026-06-05 09:22:33.276	2026-06-05 09:22:33.276	0.2	\N
cmq0pu9j10198hk8dhghnm9ls	cmpciwqq700w0hkdzjbgaqxol	29	D	Genel Test	2026-06-05 09:22:33.276	2026-06-05 09:22:33.276	0.2	\N
cmq0pu9j10199hk8dfkf7dlhm	cmpciwqq700w0hkdzjbgaqxol	30	B	Genel Test	2026-06-05 09:22:33.276	2026-06-05 09:22:33.276	0.2	\N
cmq0pu9j1019ahk8diypw7pxf	cmpciwqq700w0hkdzjbgaqxol	31	D	Genel Test	2026-06-05 09:22:33.276	2026-06-05 09:22:33.276	0.2	\N
cmq0pu9j1019bhk8d6e3d75ir	cmpciwqq700w0hkdzjbgaqxol	32	D	Genel Test	2026-06-05 09:22:33.276	2026-06-05 09:22:33.276	0.2	\N
cmq0pu9j1019chk8dlw92ords	cmpciwqq700w0hkdzjbgaqxol	33	D	Genel Test	2026-06-05 09:22:33.276	2026-06-05 09:22:33.276	0.2	\N
cmq0pu9j1019dhk8dzabn9ajh	cmpciwqq700w0hkdzjbgaqxol	34	E	Genel Test	2026-06-05 09:22:33.276	2026-06-05 09:22:33.276	0.2	\N
cmq0pu9j1019ehk8dkuc4nqqe	cmpciwqq700w0hkdzjbgaqxol	35	E	Genel Test	2026-06-05 09:22:33.276	2026-06-05 09:22:33.276	0.2	\N
cmq0pu9j1019fhk8dn2esgoh4	cmpciwqq700w0hkdzjbgaqxol	36	C	Genel Test	2026-06-05 09:22:33.276	2026-06-05 09:22:33.276	0.2	\N
cmq0pu9j1019ghk8dc0w2d1fm	cmpciwqq700w0hkdzjbgaqxol	37	C	Genel Test	2026-06-05 09:22:33.276	2026-06-05 09:22:33.276	0.2	\N
cmq0pu9j1019hhk8do2rpyrci	cmpciwqq700w0hkdzjbgaqxol	38	E	Genel Test	2026-06-05 09:22:33.276	2026-06-05 09:22:33.276	0.2	\N
cmq0pu9j1019ihk8day2yqnzl	cmpciwqq700w0hkdzjbgaqxol	39	A	Genel Test	2026-06-05 09:22:33.276	2026-06-05 09:22:33.276	0.2	\N
cmq0pu9j1019jhk8dk622dm9v	cmpciwqq700w0hkdzjbgaqxol	40	D	Genel Test	2026-06-05 09:22:33.276	2026-06-05 09:22:33.276	0.2	\N
cmq0punyx019khk8dygxzft97	cmpch8fca00rehkdz8hbidxis	1	B	Genel Test	2026-06-05 09:22:51.993	2026-06-05 09:22:51.993	0.2	\N
cmq0punyx019lhk8dy18wq6h2	cmpch8fca00rehkdz8hbidxis	2	E	Genel Test	2026-06-05 09:22:51.993	2026-06-05 09:22:51.993	0.2	\N
cmq0punyx019mhk8dgyur5u4f	cmpch8fca00rehkdz8hbidxis	3	B	Genel Test	2026-06-05 09:22:51.993	2026-06-05 09:22:51.993	0.2	\N
cmq0punyx019nhk8d6iagicuq	cmpch8fca00rehkdz8hbidxis	4	D	Genel Test	2026-06-05 09:22:51.993	2026-06-05 09:22:51.993	0.2	\N
cmq0punyx019ohk8dxw7fr3fz	cmpch8fca00rehkdz8hbidxis	5	C	Genel Test	2026-06-05 09:22:51.993	2026-06-05 09:22:51.993	0.2	\N
cmq0punyx019phk8dh2yp2sc0	cmpch8fca00rehkdz8hbidxis	6	E	Genel Test	2026-06-05 09:22:51.993	2026-06-05 09:22:51.993	0.2	\N
cmq0punyx019qhk8d4vxys4o9	cmpch8fca00rehkdz8hbidxis	7	B	Genel Test	2026-06-05 09:22:51.993	2026-06-05 09:22:51.993	0.2	\N
cmq0punyx019rhk8dn54dgw9h	cmpch8fca00rehkdz8hbidxis	8	B	Genel Test	2026-06-05 09:22:51.993	2026-06-05 09:22:51.993	0.2	\N
cmq0punyy019shk8dmvyav0a0	cmpch8fca00rehkdz8hbidxis	9	E	Genel Test	2026-06-05 09:22:51.993	2026-06-05 09:22:51.993	0.2	\N
cmq0punyy019thk8d3mqqiujo	cmpch8fca00rehkdz8hbidxis	10	D	Genel Test	2026-06-05 09:22:51.993	2026-06-05 09:22:51.993	0.2	\N
cmq0punyy019uhk8dreqo5l7j	cmpch8fca00rehkdz8hbidxis	11	A	Genel Test	2026-06-05 09:22:51.993	2026-06-05 09:22:51.993	0.2	\N
cmq0punyy019vhk8d9zukw1ok	cmpch8fca00rehkdz8hbidxis	12	E	Genel Test	2026-06-05 09:22:51.993	2026-06-05 09:22:51.993	0.2	\N
cmq0punyy019whk8djw0ml0z4	cmpch8fca00rehkdz8hbidxis	13	C	Genel Test	2026-06-05 09:22:51.993	2026-06-05 09:22:51.993	0.2	\N
cmq0punyy019xhk8dw2ulky06	cmpch8fca00rehkdz8hbidxis	14	C	Genel Test	2026-06-05 09:22:51.993	2026-06-05 09:22:51.993	0.2	\N
cmq0punyy019yhk8diazzukux	cmpch8fca00rehkdz8hbidxis	15	B	Genel Test	2026-06-05 09:22:51.993	2026-06-05 09:22:51.993	0.2	\N
cmq0p86gi006nhk8dwlz65b87	cmpwtnr2b00bghkwp97a1ohni	40	B	Genel Test	2026-06-05 09:05:22.864	2026-06-05 09:05:22.864	0.2	\N
cmq0p9c4n006ohk8dt47imkhz	cmpxsd15o001bhke6zja5eqfk	1	B	Genel Test	2026-06-05 09:06:16.871	2026-06-05 09:06:16.871	0.2	\N
cmq0p9c4n006phk8drsl1thjb	cmpxsd15o001bhke6zja5eqfk	2	B	Genel Test	2026-06-05 09:06:16.871	2026-06-05 09:06:16.871	0.2	\N
cmq0p9c4n006qhk8dty1vg0rx	cmpxsd15o001bhke6zja5eqfk	3	E	Genel Test	2026-06-05 09:06:16.871	2026-06-05 09:06:16.871	0.2	\N
cmq0p9c4n006rhk8drn0btvi2	cmpxsd15o001bhke6zja5eqfk	4	B	Genel Test	2026-06-05 09:06:16.871	2026-06-05 09:06:16.871	0.2	\N
cmq0p9c4n006shk8dk1nn8sjf	cmpxsd15o001bhke6zja5eqfk	5	D	Genel Test	2026-06-05 09:06:16.871	2026-06-05 09:06:16.871	0.2	\N
cmq0p9c4n006thk8dwpaqrp4h	cmpxsd15o001bhke6zja5eqfk	6	D	Genel Test	2026-06-05 09:06:16.871	2026-06-05 09:06:16.871	0.2	\N
cmq0p9c4n006uhk8dk5otwsb7	cmpxsd15o001bhke6zja5eqfk	7	C	Genel Test	2026-06-05 09:06:16.871	2026-06-05 09:06:16.871	0.2	\N
cmq0p9c4n006vhk8dtcmdrbp5	cmpxsd15o001bhke6zja5eqfk	8	A	Genel Test	2026-06-05 09:06:16.871	2026-06-05 09:06:16.871	0.2	\N
cmq0p9c4n006whk8d9oybgf3y	cmpxsd15o001bhke6zja5eqfk	9	C	Genel Test	2026-06-05 09:06:16.871	2026-06-05 09:06:16.871	0.2	\N
cmq0p9c4n006xhk8d9ruvghna	cmpxsd15o001bhke6zja5eqfk	10	E	Genel Test	2026-06-05 09:06:16.871	2026-06-05 09:06:16.871	0.2	\N
cmq0p9c4n006yhk8dptkayabo	cmpxsd15o001bhke6zja5eqfk	11	C	Genel Test	2026-06-05 09:06:16.871	2026-06-05 09:06:16.871	0.2	\N
cmq0p9c4n006zhk8d76v13mzs	cmpxsd15o001bhke6zja5eqfk	12	A	Genel Test	2026-06-05 09:06:16.871	2026-06-05 09:06:16.871	0.2	\N
cmq0p9c4n0070hk8d2mutsw2d	cmpxsd15o001bhke6zja5eqfk	13	B	Genel Test	2026-06-05 09:06:16.871	2026-06-05 09:06:16.871	0.2	\N
cmq0p9c4n0071hk8d4y6eg4zs	cmpxsd15o001bhke6zja5eqfk	14	E	Genel Test	2026-06-05 09:06:16.871	2026-06-05 09:06:16.871	0.2	\N
cmq0p9c4n0072hk8dbgf0kt1k	cmpxsd15o001bhke6zja5eqfk	15	D	Genel Test	2026-06-05 09:06:16.871	2026-06-05 09:06:16.871	0.2	\N
cmq0p9c4n0073hk8dc27rc4t4	cmpxsd15o001bhke6zja5eqfk	16	C	Genel Test	2026-06-05 09:06:16.871	2026-06-05 09:06:16.871	0.2	\N
cmq0p9c4o0074hk8dvfrxufc2	cmpxsd15o001bhke6zja5eqfk	17	C	Genel Test	2026-06-05 09:06:16.871	2026-06-05 09:06:16.871	0.2	\N
cmq0p9c4o0075hk8dvaaqelr8	cmpxsd15o001bhke6zja5eqfk	18	A	Genel Test	2026-06-05 09:06:16.871	2026-06-05 09:06:16.871	0.2	\N
cmq0p9c4o0076hk8d01zqtb5g	cmpxsd15o001bhke6zja5eqfk	19	A	Genel Test	2026-06-05 09:06:16.871	2026-06-05 09:06:16.871	0.2	\N
cmq0p9c4o0077hk8djf9fawx0	cmpxsd15o001bhke6zja5eqfk	20	D	Genel Test	2026-06-05 09:06:16.871	2026-06-05 09:06:16.871	0.2	\N
cmq0p9c4o0078hk8dri8yedkc	cmpxsd15o001bhke6zja5eqfk	21	C	Genel Test	2026-06-05 09:06:16.871	2026-06-05 09:06:16.871	0.2	\N
cmq0p9c4o0079hk8d1lrobekz	cmpxsd15o001bhke6zja5eqfk	22	A	Genel Test	2026-06-05 09:06:16.871	2026-06-05 09:06:16.871	0.2	\N
cmq0p9c4o007ahk8dzcvremnb	cmpxsd15o001bhke6zja5eqfk	23	B	Genel Test	2026-06-05 09:06:16.871	2026-06-05 09:06:16.871	0.2	\N
cmq0p9c4o007bhk8dhc822229	cmpxsd15o001bhke6zja5eqfk	24	C	Genel Test	2026-06-05 09:06:16.871	2026-06-05 09:06:16.871	0.2	\N
cmq0p9c4o007chk8deipd2bez	cmpxsd15o001bhke6zja5eqfk	25	E	Genel Test	2026-06-05 09:06:16.871	2026-06-05 09:06:16.871	0.2	\N
cmq0p9c4o007dhk8dkuh5iggy	cmpxsd15o001bhke6zja5eqfk	26	E	Genel Test	2026-06-05 09:06:16.871	2026-06-05 09:06:16.871	0.2	\N
cmq0p9c4o007ehk8dvvs6wrdl	cmpxsd15o001bhke6zja5eqfk	27	E	Genel Test	2026-06-05 09:06:16.871	2026-06-05 09:06:16.871	0.2	\N
cmq0p9c4o007fhk8d5did23e1	cmpxsd15o001bhke6zja5eqfk	28	D	Genel Test	2026-06-05 09:06:16.871	2026-06-05 09:06:16.871	0.2	\N
cmq0p9c4o007ghk8d3jamw6wr	cmpxsd15o001bhke6zja5eqfk	29	D	Genel Test	2026-06-05 09:06:16.871	2026-06-05 09:06:16.871	0.2	\N
cmq0p9c4o007hhk8dskm6cfaj	cmpxsd15o001bhke6zja5eqfk	30	A	Genel Test	2026-06-05 09:06:16.871	2026-06-05 09:06:16.871	0.2	\N
cmq0p9c4o007ihk8ddfst3tpr	cmpxsd15o001bhke6zja5eqfk	31	D	Genel Test	2026-06-05 09:06:16.871	2026-06-05 09:06:16.871	0.2	\N
cmq0p9c4o007jhk8d8lxdczwe	cmpxsd15o001bhke6zja5eqfk	32	B	Genel Test	2026-06-05 09:06:16.871	2026-06-05 09:06:16.871	0.2	\N
cmq0p9c4o007khk8d4k66f3wb	cmpxsd15o001bhke6zja5eqfk	33	B	Genel Test	2026-06-05 09:06:16.871	2026-06-05 09:06:16.871	0.2	\N
cmq0p9c4o007lhk8dtmo3fngc	cmpxsd15o001bhke6zja5eqfk	34	D	Genel Test	2026-06-05 09:06:16.871	2026-06-05 09:06:16.871	0.2	\N
cmq0p9c4o007mhk8dyfruf11s	cmpxsd15o001bhke6zja5eqfk	35	D	Genel Test	2026-06-05 09:06:16.871	2026-06-05 09:06:16.871	0.2	\N
cmq0p9c4o007nhk8d80558sp0	cmpxsd15o001bhke6zja5eqfk	36	A	Genel Test	2026-06-05 09:06:16.871	2026-06-05 09:06:16.871	0.2	\N
cmq0p9c4o007ohk8dbnfsn5qd	cmpxsd15o001bhke6zja5eqfk	37	A	Genel Test	2026-06-05 09:06:16.871	2026-06-05 09:06:16.871	0.2	\N
cmq0p9c4o007phk8d4px24aae	cmpxsd15o001bhke6zja5eqfk	38	E	Genel Test	2026-06-05 09:06:16.871	2026-06-05 09:06:16.871	0.2	\N
cmq0p9c4o007qhk8d9uys7zh6	cmpxsd15o001bhke6zja5eqfk	39	A	Genel Test	2026-06-05 09:06:16.871	2026-06-05 09:06:16.871	0.2	\N
cmq0p9c4o007rhk8dgoadh8lw	cmpxsd15o001bhke6zja5eqfk	40	A	Genel Test	2026-06-05 09:06:16.871	2026-06-05 09:06:16.871	0.2	\N
cmq0pgghs00hdhk8d9jb3tam2	cmpxw4fdb00ldhke6mjnc94ez	66	A	Genel Kültür	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgghs00hehk8dueflzqrj	cmpxw4fdb00ldhke6mjnc94ez	67	B	Genel Kültür	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgghs00hfhk8dxu0x9vl4	cmpxw4fdb00ldhke6mjnc94ez	68	E	Genel Kültür	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgghs00hghk8duie76o9v	cmpxw4fdb00ldhke6mjnc94ez	69	A	Genel Kültür	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgghs00hhhk8dnqiq211b	cmpxw4fdb00ldhke6mjnc94ez	70	B	Genel Kültür	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgghs00hihk8dwepsgap3	cmpxw4fdb00ldhke6mjnc94ez	71	B	Genel Kültür	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgghs00hjhk8da7dqdax7	cmpxw4fdb00ldhke6mjnc94ez	72	D	Genel Kültür	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmpzlu4lk00swhk8cv1vxluyg	cmpcf6a4t005yhkdz4769ze1s	1	A	Hukuk	2026-06-04 14:42:42.248	2026-06-04 14:42:42.248	0.2	\N
cmpzlu4lk00sxhk8cp1corgb9	cmpcf6a4t005yhkdz4769ze1s	2	A	Hukuk	2026-06-04 14:42:42.248	2026-06-04 14:42:42.248	0.2	\N
cmpzlu4lk00syhk8c3tx57ei1	cmpcf6a4t005yhkdz4769ze1s	3	B	Hukuk	2026-06-04 14:42:42.248	2026-06-04 14:42:42.248	0.2	\N
cmpzlu4lk00szhk8cks21wgol	cmpcf6a4t005yhkdz4769ze1s	4	E	Hukuk	2026-06-04 14:42:42.248	2026-06-04 14:42:42.248	0.2	\N
cmpzlu4lk00t0hk8cx9nu9yin	cmpcf6a4t005yhkdz4769ze1s	5	B	Hukuk	2026-06-04 14:42:42.248	2026-06-04 14:42:42.248	0.2	\N
cmpzlu4lk00t1hk8cvyl20clf	cmpcf6a4t005yhkdz4769ze1s	6	B	Hukuk	2026-06-04 14:42:42.248	2026-06-04 14:42:42.248	0.2	\N
cmpzlu4lk00t2hk8c4e70qlhq	cmpcf6a4t005yhkdz4769ze1s	7	B	Hukuk	2026-06-04 14:42:42.248	2026-06-04 14:42:42.248	0.2	\N
cmpzlu4lk00t3hk8caub1c4ro	cmpcf6a4t005yhkdz4769ze1s	8	B	Hukuk	2026-06-04 14:42:42.248	2026-06-04 14:42:42.248	0.2	\N
cmpzlu4lk00t4hk8cnpytjhuy	cmpcf6a4t005yhkdz4769ze1s	9	C	Hukuk	2026-06-04 14:42:42.248	2026-06-04 14:42:42.248	0.2	\N
cmpzlu4lk00t5hk8can7pl931	cmpcf6a4t005yhkdz4769ze1s	10	A	Hukuk	2026-06-04 14:42:42.248	2026-06-04 14:42:42.248	0.2	\N
cmpzlu4lk00t6hk8cdrk29jwi	cmpcf6a4t005yhkdz4769ze1s	11	A	Hukuk	2026-06-04 14:42:42.248	2026-06-04 14:42:42.248	0.2	\N
cmpzlu4lk00t7hk8c0zljutfa	cmpcf6a4t005yhkdz4769ze1s	12	C	Hukuk	2026-06-04 14:42:42.248	2026-06-04 14:42:42.248	0.2	\N
cmpzlu4lk00t8hk8c2733aj8i	cmpcf6a4t005yhkdz4769ze1s	13	D	Hukuk	2026-06-04 14:42:42.248	2026-06-04 14:42:42.248	0.2	\N
cmpzlu4lk00t9hk8cdavpwufs	cmpcf6a4t005yhkdz4769ze1s	14	E	Hukuk	2026-06-04 14:42:42.248	2026-06-04 14:42:42.248	0.2	\N
cmpzlu4lk00tahk8coq59eu4c	cmpcf6a4t005yhkdz4769ze1s	15	D	Hukuk	2026-06-04 14:42:42.248	2026-06-04 14:42:42.248	0.2	\N
cmpzlu4ll00tbhk8c4of8jkgu	cmpcf6a4t005yhkdz4769ze1s	16	C	Hukuk	2026-06-04 14:42:42.248	2026-06-04 14:42:42.248	0.2	\N
cmpzlu4ll00tchk8cojs9hlro	cmpcf6a4t005yhkdz4769ze1s	17	C	Hukuk	2026-06-04 14:42:42.248	2026-06-04 14:42:42.248	0.2	\N
cmpzlu4ll00tdhk8cem2sj6f4	cmpcf6a4t005yhkdz4769ze1s	18	A	Hukuk	2026-06-04 14:42:42.248	2026-06-04 14:42:42.248	0.2	\N
cmpzlu4ll00tehk8cvno4apc2	cmpcf6a4t005yhkdz4769ze1s	19	E	Hukuk	2026-06-04 14:42:42.248	2026-06-04 14:42:42.248	0.2	\N
cmpzlu4ll00tfhk8ccu0omjbg	cmpcf6a4t005yhkdz4769ze1s	20	E	Hukuk	2026-06-04 14:42:42.248	2026-06-04 14:42:42.248	0.2	\N
cmpzlu4ll00tghk8coyvh9w1q	cmpcf6a4t005yhkdz4769ze1s	21	E	Hukuk	2026-06-04 14:42:42.248	2026-06-04 14:42:42.248	0.2	\N
cmpzlu4ll00thhk8cq81ff3x4	cmpcf6a4t005yhkdz4769ze1s	22	C	Hukuk	2026-06-04 14:42:42.248	2026-06-04 14:42:42.248	0.2	\N
cmpzlu4ll00tihk8cmrylthnf	cmpcf6a4t005yhkdz4769ze1s	23	D	Hukuk	2026-06-04 14:42:42.248	2026-06-04 14:42:42.248	0.2	\N
cmpzlu4ll00tjhk8czopy6ztq	cmpcf6a4t005yhkdz4769ze1s	24	C	Hukuk	2026-06-04 14:42:42.248	2026-06-04 14:42:42.248	0.2	\N
cmpzlu4ll00tkhk8chmpol79x	cmpcf6a4t005yhkdz4769ze1s	25	E	Hukuk	2026-06-04 14:42:42.248	2026-06-04 14:42:42.248	0.2	\N
cmpzlu4ll00tlhk8c6dkmoh04	cmpcf6a4t005yhkdz4769ze1s	26	C	Hukuk	2026-06-04 14:42:42.248	2026-06-04 14:42:42.248	0.2	\N
cmpzlu4ll00tmhk8cdda25pwr	cmpcf6a4t005yhkdz4769ze1s	27	E	Hukuk	2026-06-04 14:42:42.248	2026-06-04 14:42:42.248	0.2	\N
cmpzlu4ll00tnhk8c0oni6pzm	cmpcf6a4t005yhkdz4769ze1s	28	C	Hukuk	2026-06-04 14:42:42.248	2026-06-04 14:42:42.248	0.2	\N
cmpzlu4ll00tohk8cvmc47gtf	cmpcf6a4t005yhkdz4769ze1s	29	D	Hukuk	2026-06-04 14:42:42.248	2026-06-04 14:42:42.248	0.2	\N
cmpzlu4ll00tphk8cj3eu2oxx	cmpcf6a4t005yhkdz4769ze1s	30	B	Hukuk	2026-06-04 14:42:42.248	2026-06-04 14:42:42.248	0.2	\N
cmpzlu4ll00tqhk8ccpw804tl	cmpcf6a4t005yhkdz4769ze1s	31	D	Hukuk	2026-06-04 14:42:42.248	2026-06-04 14:42:42.248	0.2	\N
cmpzlu4ll00trhk8czkdhwjym	cmpcf6a4t005yhkdz4769ze1s	32	A	Hukuk	2026-06-04 14:42:42.248	2026-06-04 14:42:42.248	0.2	\N
cmpzlu4ll00tshk8cdtrd2ut0	cmpcf6a4t005yhkdz4769ze1s	33	B	Hukuk	2026-06-04 14:42:42.248	2026-06-04 14:42:42.248	0.2	\N
cmpzlu4ll00tthk8c0wcrrz6o	cmpcf6a4t005yhkdz4769ze1s	34	C	Hukuk	2026-06-04 14:42:42.248	2026-06-04 14:42:42.248	0.2	\N
cmpzlu4ll00tuhk8c73ld39se	cmpcf6a4t005yhkdz4769ze1s	35	D	Hukuk	2026-06-04 14:42:42.248	2026-06-04 14:42:42.248	0.2	\N
cmpzlu4ll00tvhk8cri1yatkq	cmpcf6a4t005yhkdz4769ze1s	36	E	Hukuk	2026-06-04 14:42:42.248	2026-06-04 14:42:42.248	0.2	\N
cmpzlu4ll00twhk8cdpwbhw6r	cmpcf6a4t005yhkdz4769ze1s	37	A	Hukuk	2026-06-04 14:42:42.248	2026-06-04 14:42:42.248	0.2	\N
cmpzlu4ll00txhk8cy4v1zfnj	cmpcf6a4t005yhkdz4769ze1s	38	D	Hukuk	2026-06-04 14:42:42.248	2026-06-04 14:42:42.248	0.2	\N
cmpzlu4ll00tyhk8c4ffv6peu	cmpcf6a4t005yhkdz4769ze1s	39	C	Hukuk	2026-06-04 14:42:42.248	2026-06-04 14:42:42.248	0.2	\N
cmpzlu4ll00tzhk8ci38yefcc	cmpcf6a4t005yhkdz4769ze1s	40	B	Hukuk	2026-06-04 14:42:42.248	2026-06-04 14:42:42.248	0.2	\N
cmq0punyy019zhk8dqwwji4op	cmpch8fca00rehkdz8hbidxis	16	E	Genel Test	2026-06-05 09:22:51.993	2026-06-05 09:22:51.993	0.2	\N
cmq0punyy01a0hk8dbwqjxb2f	cmpch8fca00rehkdz8hbidxis	17	D	Genel Test	2026-06-05 09:22:51.993	2026-06-05 09:22:51.993	0.2	\N
cmq0punyy01a1hk8d0cxem61d	cmpch8fca00rehkdz8hbidxis	18	A	Genel Test	2026-06-05 09:22:51.993	2026-06-05 09:22:51.993	0.2	\N
cmq0punyy01a2hk8dy5tw29iu	cmpch8fca00rehkdz8hbidxis	19	A	Genel Test	2026-06-05 09:22:51.993	2026-06-05 09:22:51.993	0.2	\N
cmq0punyy01a3hk8db8e9nl3a	cmpch8fca00rehkdz8hbidxis	20	D	Genel Test	2026-06-05 09:22:51.993	2026-06-05 09:22:51.993	0.2	\N
cmq0punyy01a4hk8dtkfs9sxm	cmpch8fca00rehkdz8hbidxis	21	A	Genel Test	2026-06-05 09:22:51.993	2026-06-05 09:22:51.993	0.2	\N
cmq0punyy01a5hk8di14hi0r4	cmpch8fca00rehkdz8hbidxis	22	D	Genel Test	2026-06-05 09:22:51.993	2026-06-05 09:22:51.993	0.2	\N
cmq0punyy01a6hk8dlkig220o	cmpch8fca00rehkdz8hbidxis	23	E	Genel Test	2026-06-05 09:22:51.993	2026-06-05 09:22:51.993	0.2	\N
cmq0punyy01a7hk8d4d99w8j8	cmpch8fca00rehkdz8hbidxis	24	B	Genel Test	2026-06-05 09:22:51.993	2026-06-05 09:22:51.993	0.2	\N
cmq0punyy01a8hk8dw8e6a5mi	cmpch8fca00rehkdz8hbidxis	25	C	Genel Test	2026-06-05 09:22:51.993	2026-06-05 09:22:51.993	0.2	\N
cmq0punyy01a9hk8dnm8yjohr	cmpch8fca00rehkdz8hbidxis	26	B	Genel Test	2026-06-05 09:22:51.993	2026-06-05 09:22:51.993	0.2	\N
cmq0punyy01aahk8dzke7gep4	cmpch8fca00rehkdz8hbidxis	27	A	Genel Test	2026-06-05 09:22:51.993	2026-06-05 09:22:51.993	0.2	\N
cmq0punyy01abhk8dlijjualq	cmpch8fca00rehkdz8hbidxis	28	E	Genel Test	2026-06-05 09:22:51.993	2026-06-05 09:22:51.993	0.2	\N
cmq0punyy01achk8dmrndwc1r	cmpch8fca00rehkdz8hbidxis	29	C	Genel Test	2026-06-05 09:22:51.993	2026-06-05 09:22:51.993	0.2	\N
cmq0punyy01adhk8di37zc2ca	cmpch8fca00rehkdz8hbidxis	30	D	Genel Test	2026-06-05 09:22:51.993	2026-06-05 09:22:51.993	0.2	\N
cmq0punyy01aehk8dldq4ujo9	cmpch8fca00rehkdz8hbidxis	31	E	Genel Test	2026-06-05 09:22:51.993	2026-06-05 09:22:51.993	0.2	\N
cmq0punyy01afhk8djn2268qt	cmpch8fca00rehkdz8hbidxis	32	D	Genel Test	2026-06-05 09:22:51.993	2026-06-05 09:22:51.993	0.2	\N
cmq0punyy01aghk8d5gwjxcnb	cmpch8fca00rehkdz8hbidxis	33	D	Genel Test	2026-06-05 09:22:51.993	2026-06-05 09:22:51.993	0.2	\N
cmq0punyy01ahhk8drozob7nn	cmpch8fca00rehkdz8hbidxis	34	C	Genel Test	2026-06-05 09:22:51.993	2026-06-05 09:22:51.993	0.2	\N
cmq0punyy01aihk8dcmptn5ta	cmpch8fca00rehkdz8hbidxis	35	E	Genel Test	2026-06-05 09:22:51.993	2026-06-05 09:22:51.993	0.2	\N
cmq0punyy01ajhk8d2h4ns3ax	cmpch8fca00rehkdz8hbidxis	36	E	Genel Test	2026-06-05 09:22:51.993	2026-06-05 09:22:51.993	0.2	\N
cmq0punyy01akhk8dxqpfqf1d	cmpch8fca00rehkdz8hbidxis	37	C	Genel Test	2026-06-05 09:22:51.993	2026-06-05 09:22:51.993	0.2	\N
cmq0punyy01alhk8d5slf3l84	cmpch8fca00rehkdz8hbidxis	38	C	Genel Test	2026-06-05 09:22:51.993	2026-06-05 09:22:51.993	0.2	\N
cmq0punyy01amhk8d0oj1dptw	cmpch8fca00rehkdz8hbidxis	39	D	Genel Test	2026-06-05 09:22:51.993	2026-06-05 09:22:51.993	0.2	\N
cmq0punyy01anhk8dauxecbbp	cmpch8fca00rehkdz8hbidxis	40	A	Genel Test	2026-06-05 09:22:51.993	2026-06-05 09:22:51.993	0.2	\N
cmq0pe025008whk8dyapgvrec	cmpxvwgb700hrhke60gvfnxza	1	A	Genel Test	2026-06-05 09:09:54.509	2026-06-05 09:09:54.509	0.1	\N
cmq0pe025008xhk8d7qtsjmd5	cmpxvwgb700hrhke60gvfnxza	2	A	Genel Test	2026-06-05 09:09:54.509	2026-06-05 09:09:54.509	0.1	\N
cmq0pe026008yhk8dn2r13b01	cmpxvwgb700hrhke60gvfnxza	3	E	Genel Test	2026-06-05 09:09:54.509	2026-06-05 09:09:54.509	0.1	\N
cmq0pe026008zhk8dmyu35s1u	cmpxvwgb700hrhke60gvfnxza	4	B	Genel Test	2026-06-05 09:09:54.509	2026-06-05 09:09:54.509	0.1	\N
cmq0pe0260090hk8d91xhdujh	cmpxvwgb700hrhke60gvfnxza	5	A	Genel Test	2026-06-05 09:09:54.509	2026-06-05 09:09:54.509	0.1	\N
cmq0pe0260091hk8dljsiuoa1	cmpxvwgb700hrhke60gvfnxza	6	E	Genel Test	2026-06-05 09:09:54.509	2026-06-05 09:09:54.509	0.1	\N
cmq0pe0260092hk8dtzhxc1rz	cmpxvwgb700hrhke60gvfnxza	7	D	Genel Test	2026-06-05 09:09:54.509	2026-06-05 09:09:54.509	0.1	\N
cmq0pe0260093hk8demq7c6a3	cmpxvwgb700hrhke60gvfnxza	8	E	Genel Test	2026-06-05 09:09:54.509	2026-06-05 09:09:54.509	0.1	\N
cmq0pe0260094hk8d35hani80	cmpxvwgb700hrhke60gvfnxza	9	D	Genel Test	2026-06-05 09:09:54.509	2026-06-05 09:09:54.509	0.1	\N
cmq0pe0260095hk8ddqkm8qo2	cmpxvwgb700hrhke60gvfnxza	10	B	Genel Test	2026-06-05 09:09:54.509	2026-06-05 09:09:54.509	0.1	\N
cmq0pe0260096hk8dlu8q7vj5	cmpxvwgb700hrhke60gvfnxza	11	E	Genel Test	2026-06-05 09:09:54.509	2026-06-05 09:09:54.509	0.1	\N
cmq0pe0260097hk8d7arv4dwz	cmpxvwgb700hrhke60gvfnxza	12	D	Genel Test	2026-06-05 09:09:54.509	2026-06-05 09:09:54.509	0.1	\N
cmq0pe0260098hk8djxp0g8ro	cmpxvwgb700hrhke60gvfnxza	13	D	Genel Test	2026-06-05 09:09:54.509	2026-06-05 09:09:54.509	0.1	\N
cmq0pe0260099hk8dr1q8jjw9	cmpxvwgb700hrhke60gvfnxza	14	A	Genel Test	2026-06-05 09:09:54.509	2026-06-05 09:09:54.509	0.1	\N
cmq0pe026009ahk8d9hi686fw	cmpxvwgb700hrhke60gvfnxza	15	B	Genel Test	2026-06-05 09:09:54.509	2026-06-05 09:09:54.509	0.1	\N
cmq0pe026009bhk8du7w21q8n	cmpxvwgb700hrhke60gvfnxza	16	B	Genel Test	2026-06-05 09:09:54.509	2026-06-05 09:09:54.509	0.1	\N
cmq0pe026009chk8dixuqxi7p	cmpxvwgb700hrhke60gvfnxza	17	B	Genel Test	2026-06-05 09:09:54.509	2026-06-05 09:09:54.509	0.1	\N
cmq0pe026009dhk8digb1h6me	cmpxvwgb700hrhke60gvfnxza	18	B	Genel Test	2026-06-05 09:09:54.509	2026-06-05 09:09:54.509	0.1	\N
cmq0pk3uf00qohk8d5cp6oxm3	cmpxumqvw00aqhke6ocrgteiz	1	B	Genel Test	2026-06-05 09:14:39.351	2026-06-05 09:14:39.351	0.1	\N
cmq0pk3uf00qphk8d13d1rr9m	cmpxumqvw00aqhke6ocrgteiz	2	C	Genel Test	2026-06-05 09:14:39.351	2026-06-05 09:14:39.351	0.1	\N
cmq0pk3uf00qqhk8d5na5rhe0	cmpxumqvw00aqhke6ocrgteiz	3	A	Genel Test	2026-06-05 09:14:39.351	2026-06-05 09:14:39.351	0.1	\N
cmq0pk3uf00qrhk8dh33yx3ce	cmpxumqvw00aqhke6ocrgteiz	4	C	Genel Test	2026-06-05 09:14:39.351	2026-06-05 09:14:39.351	0.1	\N
cmq0pk3uf00qshk8d90cpjoew	cmpxumqvw00aqhke6ocrgteiz	5	E	Genel Test	2026-06-05 09:14:39.351	2026-06-05 09:14:39.351	0.1	\N
cmq0pk3uf00qthk8db4id7x3d	cmpxumqvw00aqhke6ocrgteiz	6	C	Genel Test	2026-06-05 09:14:39.351	2026-06-05 09:14:39.351	0.1	\N
cmq0pk3uf00quhk8dy89x8t2r	cmpxumqvw00aqhke6ocrgteiz	7	D	Genel Test	2026-06-05 09:14:39.351	2026-06-05 09:14:39.351	0.1	\N
cmq0pk3uf00qvhk8d5vs3odlv	cmpxumqvw00aqhke6ocrgteiz	8	C	Genel Test	2026-06-05 09:14:39.351	2026-06-05 09:14:39.351	0.1	\N
cmq0pk3uf00qwhk8dzf89n6u6	cmpxumqvw00aqhke6ocrgteiz	9	B	Genel Test	2026-06-05 09:14:39.351	2026-06-05 09:14:39.351	0.1	\N
cmq0pk3ug00qxhk8dlp1iub5i	cmpxumqvw00aqhke6ocrgteiz	10	B	Genel Test	2026-06-05 09:14:39.351	2026-06-05 09:14:39.351	0.1	\N
cmq0pk3ug00qyhk8df69gr8qa	cmpxumqvw00aqhke6ocrgteiz	11	E	Genel Test	2026-06-05 09:14:39.351	2026-06-05 09:14:39.351	0.1	\N
cmq0pk3ug00qzhk8ddfpo676e	cmpxumqvw00aqhke6ocrgteiz	12	D	Genel Test	2026-06-05 09:14:39.351	2026-06-05 09:14:39.351	0.1	\N
cmq0pk3ug00r0hk8d9y21a05b	cmpxumqvw00aqhke6ocrgteiz	13	C	Genel Test	2026-06-05 09:14:39.351	2026-06-05 09:14:39.351	0.1	\N
cmq0pk3ug00r1hk8d875oyk0d	cmpxumqvw00aqhke6ocrgteiz	14	E	Genel Test	2026-06-05 09:14:39.351	2026-06-05 09:14:39.351	0.1	\N
cmq0pk3ug00r2hk8d4agwj8yq	cmpxumqvw00aqhke6ocrgteiz	15	D	Genel Test	2026-06-05 09:14:39.351	2026-06-05 09:14:39.351	0.1	\N
cmq0pk3ug00r3hk8dvaf78p7y	cmpxumqvw00aqhke6ocrgteiz	16	B	Genel Test	2026-06-05 09:14:39.351	2026-06-05 09:14:39.351	0.1	\N
cmq0pe026009ehk8dx00hh39b	cmpxvwgb700hrhke60gvfnxza	19	B	Genel Test	2026-06-05 09:09:54.509	2026-06-05 09:09:54.509	0.1	\N
cmq0pe026009fhk8dn0c9i7oq	cmpxvwgb700hrhke60gvfnxza	20	D	Genel Test	2026-06-05 09:09:54.509	2026-06-05 09:09:54.509	0.1	\N
cmq0pe026009ghk8dssbd3swr	cmpxvwgb700hrhke60gvfnxza	21	D	Genel Test	2026-06-05 09:09:54.509	2026-06-05 09:09:54.509	0.1	\N
cmq0pe026009hhk8d88hn0pyh	cmpxvwgb700hrhke60gvfnxza	22	A	Genel Test	2026-06-05 09:09:54.509	2026-06-05 09:09:54.509	0.1	\N
cmq0pe026009ihk8do9qfsg50	cmpxvwgb700hrhke60gvfnxza	23	D	Genel Test	2026-06-05 09:09:54.509	2026-06-05 09:09:54.509	0.1	\N
cmq0pe026009jhk8d27mwylq2	cmpxvwgb700hrhke60gvfnxza	24	C	Genel Test	2026-06-05 09:09:54.509	2026-06-05 09:09:54.509	0.1	\N
cmq0pe026009khk8dqfd7tjjc	cmpxvwgb700hrhke60gvfnxza	25	D	Genel Test	2026-06-05 09:09:54.509	2026-06-05 09:09:54.509	0.1	\N
cmq0pe026009lhk8d417zrx0a	cmpxvwgb700hrhke60gvfnxza	26	D	Genel Test	2026-06-05 09:09:54.509	2026-06-05 09:09:54.509	0.1	\N
cmq0pe026009mhk8dm5p0bawg	cmpxvwgb700hrhke60gvfnxza	27	A	Genel Test	2026-06-05 09:09:54.509	2026-06-05 09:09:54.509	0.1	\N
cmq0pe026009nhk8dwlje9p88	cmpxvwgb700hrhke60gvfnxza	28	E	Genel Test	2026-06-05 09:09:54.509	2026-06-05 09:09:54.509	0.1	\N
cmq0pe026009ohk8dpnrn1ag4	cmpxvwgb700hrhke60gvfnxza	29	B	Genel Test	2026-06-05 09:09:54.509	2026-06-05 09:09:54.509	0.1	\N
cmq0pe026009phk8dys7thss7	cmpxvwgb700hrhke60gvfnxza	30	D	Genel Test	2026-06-05 09:09:54.509	2026-06-05 09:09:54.509	0.1	\N
cmq0pe026009qhk8dnwqluqlx	cmpxvwgb700hrhke60gvfnxza	31	A	Genel Test	2026-06-05 09:09:54.509	2026-06-05 09:09:54.509	0.1	\N
cmq0pe026009rhk8drx4zci0e	cmpxvwgb700hrhke60gvfnxza	32	C	Genel Test	2026-06-05 09:09:54.509	2026-06-05 09:09:54.509	0.1	\N
cmq0pe026009shk8duygwwq1b	cmpxvwgb700hrhke60gvfnxza	33	E	Genel Test	2026-06-05 09:09:54.509	2026-06-05 09:09:54.509	0.1	\N
cmq0pe027009thk8df4c3hp6g	cmpxvwgb700hrhke60gvfnxza	34	A	Genel Test	2026-06-05 09:09:54.509	2026-06-05 09:09:54.509	0.1	\N
cmq0pe027009uhk8ddqfnzxic	cmpxvwgb700hrhke60gvfnxza	35	C	Genel Test	2026-06-05 09:09:54.509	2026-06-05 09:09:54.509	0.1	\N
cmq0pe027009vhk8d72hsv4vv	cmpxvwgb700hrhke60gvfnxza	36	B	Genel Test	2026-06-05 09:09:54.509	2026-06-05 09:09:54.509	0.1	\N
cmq0pe027009whk8drxb4cvqn	cmpxvwgb700hrhke60gvfnxza	37	B	Genel Test	2026-06-05 09:09:54.509	2026-06-05 09:09:54.509	0.1	\N
cmq0pe027009xhk8d9665yonv	cmpxvwgb700hrhke60gvfnxza	38	E	Genel Test	2026-06-05 09:09:54.509	2026-06-05 09:09:54.509	0.1	\N
cmq0pe027009yhk8dm0kvdqtf	cmpxvwgb700hrhke60gvfnxza	39	A	Genel Test	2026-06-05 09:09:54.509	2026-06-05 09:09:54.509	0.1	\N
cmq0pe027009zhk8d20847mul	cmpxvwgb700hrhke60gvfnxza	40	C	Genel Test	2026-06-05 09:09:54.509	2026-06-05 09:09:54.509	0.1	\N
cmq0pk3ug00r4hk8d2bmqb1s0	cmpxumqvw00aqhke6ocrgteiz	17	A	Genel Test	2026-06-05 09:14:39.351	2026-06-05 09:14:39.351	0.1	\N
cmq0pk3ug00r5hk8djobrf0tb	cmpxumqvw00aqhke6ocrgteiz	18	A	Genel Test	2026-06-05 09:14:39.351	2026-06-05 09:14:39.351	0.1	\N
cmq0pk3ug00r6hk8dozx6up6a	cmpxumqvw00aqhke6ocrgteiz	19	E	Genel Test	2026-06-05 09:14:39.351	2026-06-05 09:14:39.351	0.1	\N
cmq0pk3ug00r7hk8dblapu2qn	cmpxumqvw00aqhke6ocrgteiz	20	C	Genel Test	2026-06-05 09:14:39.351	2026-06-05 09:14:39.351	0.1	\N
cmq0pk3ug00r8hk8dqwxb6434	cmpxumqvw00aqhke6ocrgteiz	21	C	Genel Test	2026-06-05 09:14:39.351	2026-06-05 09:14:39.351	0.1	\N
cmq0pk3ug00r9hk8dccdnr26h	cmpxumqvw00aqhke6ocrgteiz	22	C	Genel Test	2026-06-05 09:14:39.351	2026-06-05 09:14:39.351	0.1	\N
cmq0pk3ug00rahk8dj7h3xucq	cmpxumqvw00aqhke6ocrgteiz	23	B	Genel Test	2026-06-05 09:14:39.351	2026-06-05 09:14:39.351	0.1	\N
cmq0pk3ug00rbhk8da0drrai3	cmpxumqvw00aqhke6ocrgteiz	24	E	Genel Test	2026-06-05 09:14:39.351	2026-06-05 09:14:39.351	0.1	\N
cmq0pk3ug00rchk8db630gwo6	cmpxumqvw00aqhke6ocrgteiz	25	B	Genel Test	2026-06-05 09:14:39.351	2026-06-05 09:14:39.351	0.1	\N
cmq0pk3ug00rdhk8d70d9lezo	cmpxumqvw00aqhke6ocrgteiz	26	C	Genel Test	2026-06-05 09:14:39.351	2026-06-05 09:14:39.351	0.1	\N
cmq0pk3ug00rehk8dsriormli	cmpxumqvw00aqhke6ocrgteiz	27	D	Genel Test	2026-06-05 09:14:39.351	2026-06-05 09:14:39.351	0.1	\N
cmq0pk3ug00rfhk8d4yn3qn6y	cmpxumqvw00aqhke6ocrgteiz	28	E	Genel Test	2026-06-05 09:14:39.351	2026-06-05 09:14:39.351	0.1	\N
cmq0pk3ug00rghk8df252ea7q	cmpxumqvw00aqhke6ocrgteiz	29	B	Genel Test	2026-06-05 09:14:39.351	2026-06-05 09:14:39.351	0.1	\N
cmq0pk3ug00rhhk8du3ul11du	cmpxumqvw00aqhke6ocrgteiz	30	A	Genel Test	2026-06-05 09:14:39.351	2026-06-05 09:14:39.351	0.1	\N
cmq0pk3ug00rihk8dqzph1zw6	cmpxumqvw00aqhke6ocrgteiz	31	D	Genel Test	2026-06-05 09:14:39.351	2026-06-05 09:14:39.351	0.1	\N
cmq0pk3ug00rjhk8djyc470vj	cmpxumqvw00aqhke6ocrgteiz	32	D	Genel Test	2026-06-05 09:14:39.351	2026-06-05 09:14:39.351	0.1	\N
cmq0pk3ug00rkhk8dae7pjer1	cmpxumqvw00aqhke6ocrgteiz	33	D	Genel Test	2026-06-05 09:14:39.351	2026-06-05 09:14:39.351	0.1	\N
cmq0pk3ug00rlhk8du5hhe1co	cmpxumqvw00aqhke6ocrgteiz	34	B	Genel Test	2026-06-05 09:14:39.351	2026-06-05 09:14:39.351	0.1	\N
cmq0pk3ug00rmhk8dmrbl40n5	cmpxumqvw00aqhke6ocrgteiz	35	B	Genel Test	2026-06-05 09:14:39.351	2026-06-05 09:14:39.351	0.1	\N
cmq0pk3ug00rnhk8d6f5ycy01	cmpxumqvw00aqhke6ocrgteiz	36	D	Genel Test	2026-06-05 09:14:39.351	2026-06-05 09:14:39.351	0.1	\N
cmq0pk3ug00rohk8dc2lfbt62	cmpxumqvw00aqhke6ocrgteiz	37	B	Genel Test	2026-06-05 09:14:39.351	2026-06-05 09:14:39.351	0.1	\N
cmq0pk3ug00rphk8dt4whvuyj	cmpxumqvw00aqhke6ocrgteiz	38	E	Genel Test	2026-06-05 09:14:39.351	2026-06-05 09:14:39.351	0.1	\N
cmq0pk3ug00rqhk8dyd846g55	cmpxumqvw00aqhke6ocrgteiz	39	D	Genel Test	2026-06-05 09:14:39.351	2026-06-05 09:14:39.351	0.1	\N
cmq0pk3ug00rrhk8dv8bweqed	cmpxumqvw00aqhke6ocrgteiz	40	D	Genel Test	2026-06-05 09:14:39.351	2026-06-05 09:14:39.351	0.1	\N
cmq0qajqf01aohk8dynda286q	cmpcfzz8p00q7hkdzbyqstd86	1	B	Genel Test	2026-06-05 09:35:12.999	2026-06-05 09:35:12.999	0.2	\N
cmq0qajqf01aphk8dxxnv3gbq	cmpcfzz8p00q7hkdzbyqstd86	2	A	Genel Test	2026-06-05 09:35:12.999	2026-06-05 09:35:12.999	0.2	\N
cmq0qajqf01aqhk8dam55r84x	cmpcfzz8p00q7hkdzbyqstd86	3	B	Genel Test	2026-06-05 09:35:12.999	2026-06-05 09:35:12.999	0.2	\N
cmq0qajqf01arhk8dqcfng4kg	cmpcfzz8p00q7hkdzbyqstd86	4	E	Genel Test	2026-06-05 09:35:12.999	2026-06-05 09:35:12.999	0.2	\N
cmq0qajqg01ashk8dj3pn8lg8	cmpcfzz8p00q7hkdzbyqstd86	5	C	Genel Test	2026-06-05 09:35:12.999	2026-06-05 09:35:12.999	0.2	\N
cmq0qajqg01athk8d58cmddle	cmpcfzz8p00q7hkdzbyqstd86	6	B	Genel Test	2026-06-05 09:35:12.999	2026-06-05 09:35:12.999	0.2	\N
cmq0qajqg01auhk8djskyn0ct	cmpcfzz8p00q7hkdzbyqstd86	7	E	Genel Test	2026-06-05 09:35:12.999	2026-06-05 09:35:12.999	0.2	\N
cmq0qajqg01avhk8d2ffa7866	cmpcfzz8p00q7hkdzbyqstd86	8	E	Genel Test	2026-06-05 09:35:12.999	2026-06-05 09:35:12.999	0.2	\N
cmq0qajqg01awhk8dooznmuct	cmpcfzz8p00q7hkdzbyqstd86	9	C	Genel Test	2026-06-05 09:35:12.999	2026-06-05 09:35:12.999	0.2	\N
cmq0qajqg01axhk8d8a4ttad7	cmpcfzz8p00q7hkdzbyqstd86	10	C	Genel Test	2026-06-05 09:35:12.999	2026-06-05 09:35:12.999	0.2	\N
cmq0qajqg01ayhk8d71p4xrvz	cmpcfzz8p00q7hkdzbyqstd86	11	E	Genel Test	2026-06-05 09:35:12.999	2026-06-05 09:35:12.999	0.2	\N
cmq0qajqg01azhk8db8ujtuwg	cmpcfzz8p00q7hkdzbyqstd86	12	C	Genel Test	2026-06-05 09:35:12.999	2026-06-05 09:35:12.999	0.2	\N
cmq0qajqg01b0hk8dkxmit92a	cmpcfzz8p00q7hkdzbyqstd86	13	C	Genel Test	2026-06-05 09:35:12.999	2026-06-05 09:35:12.999	0.2	\N
cmq0qajqg01b1hk8d8lv1h9ks	cmpcfzz8p00q7hkdzbyqstd86	14	D	Genel Test	2026-06-05 09:35:12.999	2026-06-05 09:35:12.999	0.2	\N
cmq0qajqg01b2hk8de8r6iolc	cmpcfzz8p00q7hkdzbyqstd86	15	B	Genel Test	2026-06-05 09:35:12.999	2026-06-05 09:35:12.999	0.2	\N
cmq0qajqg01b3hk8doeqf7tdm	cmpcfzz8p00q7hkdzbyqstd86	16	B	Genel Test	2026-06-05 09:35:12.999	2026-06-05 09:35:12.999	0.2	\N
cmq0qajqg01b4hk8dsvmjunfd	cmpcfzz8p00q7hkdzbyqstd86	17	C	Genel Test	2026-06-05 09:35:12.999	2026-06-05 09:35:12.999	0.2	\N
cmq0qajqg01b5hk8d8ill3caj	cmpcfzz8p00q7hkdzbyqstd86	18	C	Genel Test	2026-06-05 09:35:12.999	2026-06-05 09:35:12.999	0.2	\N
cmq0qajqg01b6hk8dsmbdmro3	cmpcfzz8p00q7hkdzbyqstd86	19	C	Genel Test	2026-06-05 09:35:12.999	2026-06-05 09:35:12.999	0.2	\N
cmq0qajqg01b7hk8dnc93o29q	cmpcfzz8p00q7hkdzbyqstd86	20	B	Genel Test	2026-06-05 09:35:12.999	2026-06-05 09:35:12.999	0.2	\N
cmq0qajqg01b8hk8d4lowqn98	cmpcfzz8p00q7hkdzbyqstd86	21	A	Genel Test	2026-06-05 09:35:12.999	2026-06-05 09:35:12.999	0.2	\N
cmq0qajqg01b9hk8dir9p8irh	cmpcfzz8p00q7hkdzbyqstd86	22	D	Genel Test	2026-06-05 09:35:12.999	2026-06-05 09:35:12.999	0.2	\N
cmq0qajqg01bahk8d6a5l7nfv	cmpcfzz8p00q7hkdzbyqstd86	23	D	Genel Test	2026-06-05 09:35:12.999	2026-06-05 09:35:12.999	0.2	\N
cmq0qajqg01bbhk8d67y751zc	cmpcfzz8p00q7hkdzbyqstd86	24	E	Genel Test	2026-06-05 09:35:12.999	2026-06-05 09:35:12.999	0.2	\N
cmq0qajqg01bchk8doqubxtzi	cmpcfzz8p00q7hkdzbyqstd86	25	E	Genel Test	2026-06-05 09:35:12.999	2026-06-05 09:35:12.999	0.2	\N
cmq0qajqg01bdhk8dshfs9nn1	cmpcfzz8p00q7hkdzbyqstd86	26	D	Genel Test	2026-06-05 09:35:12.999	2026-06-05 09:35:12.999	0.2	\N
cmq0qajqg01behk8dzaamxy48	cmpcfzz8p00q7hkdzbyqstd86	27	B	Genel Test	2026-06-05 09:35:12.999	2026-06-05 09:35:12.999	0.2	\N
cmq0qajqg01bfhk8d7vk59jv2	cmpcfzz8p00q7hkdzbyqstd86	28	D	Genel Test	2026-06-05 09:35:12.999	2026-06-05 09:35:12.999	0.2	\N
cmq0qajqg01bghk8donk8ejlc	cmpcfzz8p00q7hkdzbyqstd86	29	D	Genel Test	2026-06-05 09:35:12.999	2026-06-05 09:35:12.999	0.2	\N
cmq0qajqg01bhhk8dxnt9p5uc	cmpcfzz8p00q7hkdzbyqstd86	30	C	Genel Test	2026-06-05 09:35:12.999	2026-06-05 09:35:12.999	0.2	\N
cmq0qajqg01bihk8dffpv1y1j	cmpcfzz8p00q7hkdzbyqstd86	31	D	Genel Test	2026-06-05 09:35:12.999	2026-06-05 09:35:12.999	0.2	\N
cmq0qajqg01bjhk8dnq7npry9	cmpcfzz8p00q7hkdzbyqstd86	32	B	Genel Test	2026-06-05 09:35:12.999	2026-06-05 09:35:12.999	0.2	\N
cmq0qajqg01bkhk8d811wyv0c	cmpcfzz8p00q7hkdzbyqstd86	33	B	Genel Test	2026-06-05 09:35:12.999	2026-06-05 09:35:12.999	0.2	\N
cmq0qajqg01blhk8djcr8tumb	cmpcfzz8p00q7hkdzbyqstd86	34	D	Genel Test	2026-06-05 09:35:12.999	2026-06-05 09:35:12.999	0.2	\N
cmq0qajqg01bmhk8dadn4dy2l	cmpcfzz8p00q7hkdzbyqstd86	35	D	Genel Test	2026-06-05 09:35:12.999	2026-06-05 09:35:12.999	0.2	\N
cmq0qajqh01bnhk8dtmoy4ug8	cmpcfzz8p00q7hkdzbyqstd86	36	E	Genel Test	2026-06-05 09:35:12.999	2026-06-05 09:35:12.999	0.2	\N
cmq0qajqh01bohk8d1ojnilu2	cmpcfzz8p00q7hkdzbyqstd86	37	A	Genel Test	2026-06-05 09:35:12.999	2026-06-05 09:35:12.999	0.2	\N
cmq0qajqh01bphk8dy7kt1rbx	cmpcfzz8p00q7hkdzbyqstd86	38	B	Genel Test	2026-06-05 09:35:12.999	2026-06-05 09:35:12.999	0.2	\N
cmq0qajqh01bqhk8d4v257ftk	cmpcfzz8p00q7hkdzbyqstd86	39	D	Genel Test	2026-06-05 09:35:12.999	2026-06-05 09:35:12.999	0.2	\N
cmq0qajqh01brhk8dff5mk4zv	cmpcfzz8p00q7hkdzbyqstd86	40	B	Genel Test	2026-06-05 09:35:12.999	2026-06-05 09:35:12.999	0.2	\N
cmq0qaxm401bshk8d72rixhlj	cmpfka7qt01xqhkzbwuyum22o	1	E	Genel Yetenek	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm401bthk8djf3kmcnc	cmpfka7qt01xqhkzbwuyum22o	2	D	Genel Yetenek	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm401buhk8d6nczm57u	cmpfka7qt01xqhkzbwuyum22o	3	B	Genel Yetenek	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm401bvhk8du6lplm30	cmpfka7qt01xqhkzbwuyum22o	4	D	Genel Yetenek	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm401bwhk8d8xvqpmb5	cmpfka7qt01xqhkzbwuyum22o	5	C	Genel Yetenek	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm401bxhk8d46q03voj	cmpfka7qt01xqhkzbwuyum22o	6	A	Genel Yetenek	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm401byhk8dfphtxbxv	cmpfka7qt01xqhkzbwuyum22o	7	A	Genel Yetenek	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm401bzhk8d5l4rnj9s	cmpfka7qt01xqhkzbwuyum22o	8	D	Genel Yetenek	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm401c0hk8dnq2a23mt	cmpfka7qt01xqhkzbwuyum22o	9	B	Genel Yetenek	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm401c1hk8dwiy7qnr9	cmpfka7qt01xqhkzbwuyum22o	10	D	Genel Yetenek	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm401c2hk8dss5nbfvu	cmpfka7qt01xqhkzbwuyum22o	11	B	Genel Yetenek	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm401c3hk8dis56v370	cmpfka7qt01xqhkzbwuyum22o	12	B	Genel Yetenek	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm401c4hk8d0umhjfkw	cmpfka7qt01xqhkzbwuyum22o	13	C	Genel Yetenek	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm401c5hk8dvan78nbx	cmpfka7qt01xqhkzbwuyum22o	14	D	Genel Yetenek	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm401c6hk8d8hggjs9h	cmpfka7qt01xqhkzbwuyum22o	15	D	Genel Yetenek	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm401c7hk8d0v6qrgfy	cmpfka7qt01xqhkzbwuyum22o	16	A	Genel Yetenek	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm401c8hk8dz3vj713x	cmpfka7qt01xqhkzbwuyum22o	17	A	Genel Yetenek	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm401c9hk8dyikednkg	cmpfka7qt01xqhkzbwuyum22o	18	B	Genel Yetenek	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm401cahk8dii9ha9ph	cmpfka7qt01xqhkzbwuyum22o	19	D	Genel Yetenek	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm401cbhk8d9b2jyxsp	cmpfka7qt01xqhkzbwuyum22o	20	A	Genel Yetenek	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm401cchk8dwcka3506	cmpfka7qt01xqhkzbwuyum22o	21	A	Genel Yetenek	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm401cdhk8d6ztqjgoq	cmpfka7qt01xqhkzbwuyum22o	22	C	Genel Yetenek	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm401cehk8dn6akhyrn	cmpfka7qt01xqhkzbwuyum22o	23	C	Genel Yetenek	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm501cfhk8debltymvo	cmpfka7qt01xqhkzbwuyum22o	24	A	Genel Yetenek	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm501cghk8d54h53kxr	cmpfka7qt01xqhkzbwuyum22o	25	B	Genel Yetenek	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm501chhk8dy9jjb6k5	cmpfka7qt01xqhkzbwuyum22o	26	C	Genel Yetenek	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm501cihk8dm1guxfgo	cmpfka7qt01xqhkzbwuyum22o	27	C	Genel Yetenek	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm501cjhk8dw8hkdv2b	cmpfka7qt01xqhkzbwuyum22o	28	A	Genel Yetenek	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm501ckhk8dmp219jw2	cmpfka7qt01xqhkzbwuyum22o	29	B	Genel Yetenek	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm501clhk8dpbcfcl6b	cmpfka7qt01xqhkzbwuyum22o	30	A	Genel Yetenek	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm501cmhk8da466yorx	cmpfka7qt01xqhkzbwuyum22o	31	A	Genel Yetenek	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm501cnhk8dak1a7bem	cmpfka7qt01xqhkzbwuyum22o	32	E	Genel Yetenek	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm501cohk8dsgcazmke	cmpfka7qt01xqhkzbwuyum22o	33	C	Genel Yetenek	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm501cphk8dwr4lxwl9	cmpfka7qt01xqhkzbwuyum22o	34	A	Genel Yetenek	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm501cqhk8ds1ji2q6y	cmpfka7qt01xqhkzbwuyum22o	35	A	Genel Yetenek	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm501crhk8dzm5kq83h	cmpfka7qt01xqhkzbwuyum22o	36	B	Genel Yetenek	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm501cshk8d49zxdvm0	cmpfka7qt01xqhkzbwuyum22o	37	E	Genel Yetenek	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm501cthk8du6dipklp	cmpfka7qt01xqhkzbwuyum22o	38	D	Genel Yetenek	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm501cuhk8do5g4aocu	cmpfka7qt01xqhkzbwuyum22o	39	E	Genel Yetenek	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm501cvhk8d5szfwk41	cmpfka7qt01xqhkzbwuyum22o	40	C	Genel Yetenek	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm501cwhk8d7ul94bq7	cmpfka7qt01xqhkzbwuyum22o	41	E	Genel Yetenek	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0pf0yn00b4hk8dvh6y04eg	cmpxw9h0j00r6hke6jgtdhnth	1	E	Genel Test	2026-06-05 09:10:42.335	2026-06-05 09:10:42.335	0.1	\N
cmq0pf0yn00b5hk8dmfr4vl2g	cmpxw9h0j00r6hke6jgtdhnth	2	B	Genel Test	2026-06-05 09:10:42.335	2026-06-05 09:10:42.335	0.1	\N
cmq0pf0yn00b6hk8dagv3axwk	cmpxw9h0j00r6hke6jgtdhnth	3	B	Genel Test	2026-06-05 09:10:42.335	2026-06-05 09:10:42.335	0.1	\N
cmq0pf0yn00b7hk8d9dspzknq	cmpxw9h0j00r6hke6jgtdhnth	4	B	Genel Test	2026-06-05 09:10:42.335	2026-06-05 09:10:42.335	0.1	\N
cmq0pf0yn00b8hk8d70twekvj	cmpxw9h0j00r6hke6jgtdhnth	5	D	Genel Test	2026-06-05 09:10:42.335	2026-06-05 09:10:42.335	0.1	\N
cmq0pf0yn00b9hk8djm5uuzlu	cmpxw9h0j00r6hke6jgtdhnth	6	C	Genel Test	2026-06-05 09:10:42.335	2026-06-05 09:10:42.335	0.1	\N
cmq0pf0yn00bahk8d31xwlpd3	cmpxw9h0j00r6hke6jgtdhnth	7	A	Genel Test	2026-06-05 09:10:42.335	2026-06-05 09:10:42.335	0.1	\N
cmq0pf0yn00bbhk8db4r4y6xd	cmpxw9h0j00r6hke6jgtdhnth	8	A	Genel Test	2026-06-05 09:10:42.335	2026-06-05 09:10:42.335	0.1	\N
cmq0pf0yn00bchk8d5lltn0xu	cmpxw9h0j00r6hke6jgtdhnth	9	C	Genel Test	2026-06-05 09:10:42.335	2026-06-05 09:10:42.335	0.1	\N
cmq0pf0yn00bdhk8dkx1b8xt8	cmpxw9h0j00r6hke6jgtdhnth	10	A	Genel Test	2026-06-05 09:10:42.335	2026-06-05 09:10:42.335	0.1	\N
cmq0pf0yn00behk8dl99zmm27	cmpxw9h0j00r6hke6jgtdhnth	11	D	Genel Test	2026-06-05 09:10:42.335	2026-06-05 09:10:42.335	0.1	\N
cmq0pf0yn00bfhk8dv28jd7hn	cmpxw9h0j00r6hke6jgtdhnth	12	D	Genel Test	2026-06-05 09:10:42.335	2026-06-05 09:10:42.335	0.1	\N
cmq0pf0yn00bghk8dk8iml675	cmpxw9h0j00r6hke6jgtdhnth	13	B	Genel Test	2026-06-05 09:10:42.335	2026-06-05 09:10:42.335	0.1	\N
cmq0pf0yn00bhhk8dszmd09yt	cmpxw9h0j00r6hke6jgtdhnth	14	B	Genel Test	2026-06-05 09:10:42.335	2026-06-05 09:10:42.335	0.1	\N
cmq0pf0yn00bihk8d256vqa41	cmpxw9h0j00r6hke6jgtdhnth	15	A	Genel Test	2026-06-05 09:10:42.335	2026-06-05 09:10:42.335	0.1	\N
cmq0pf0yn00bjhk8dr65eumki	cmpxw9h0j00r6hke6jgtdhnth	16	B	Genel Test	2026-06-05 09:10:42.335	2026-06-05 09:10:42.335	0.1	\N
cmq0pf0yo00bkhk8dcvlatjj9	cmpxw9h0j00r6hke6jgtdhnth	17	D	Genel Test	2026-06-05 09:10:42.335	2026-06-05 09:10:42.335	0.1	\N
cmq0pf0yo00blhk8dg0ekdv3v	cmpxw9h0j00r6hke6jgtdhnth	18	B	Genel Test	2026-06-05 09:10:42.335	2026-06-05 09:10:42.335	0.1	\N
cmq0pf0yo00bmhk8dat0phl8u	cmpxw9h0j00r6hke6jgtdhnth	19	E	Genel Test	2026-06-05 09:10:42.335	2026-06-05 09:10:42.335	0.1	\N
cmq0pf0yo00bnhk8dhse0ad7s	cmpxw9h0j00r6hke6jgtdhnth	20	E	Genel Test	2026-06-05 09:10:42.335	2026-06-05 09:10:42.335	0.1	\N
cmq0pf0yo00bohk8dpjascqcz	cmpxw9h0j00r6hke6jgtdhnth	21	D	Genel Test	2026-06-05 09:10:42.335	2026-06-05 09:10:42.335	0.1	\N
cmq0pf0yo00bphk8drg215h8c	cmpxw9h0j00r6hke6jgtdhnth	22	B	Genel Test	2026-06-05 09:10:42.335	2026-06-05 09:10:42.335	0.1	\N
cmq0pf0yo00bqhk8dphuaz7s5	cmpxw9h0j00r6hke6jgtdhnth	23	E	Genel Test	2026-06-05 09:10:42.335	2026-06-05 09:10:42.335	0.1	\N
cmq0pf0yo00brhk8dft64cn00	cmpxw9h0j00r6hke6jgtdhnth	24	A	Genel Test	2026-06-05 09:10:42.335	2026-06-05 09:10:42.335	0.1	\N
cmq0pf0yo00bshk8dhftxdzhm	cmpxw9h0j00r6hke6jgtdhnth	25	A	Genel Test	2026-06-05 09:10:42.335	2026-06-05 09:10:42.335	0.1	\N
cmq0pf0yo00bthk8d61cz9f61	cmpxw9h0j00r6hke6jgtdhnth	26	D	Genel Test	2026-06-05 09:10:42.335	2026-06-05 09:10:42.335	0.1	\N
cmq0pf0yo00buhk8dqqdj5021	cmpxw9h0j00r6hke6jgtdhnth	27	A	Genel Test	2026-06-05 09:10:42.335	2026-06-05 09:10:42.335	0.1	\N
cmq0pf0yo00bvhk8dudw0hmcu	cmpxw9h0j00r6hke6jgtdhnth	28	A	Genel Test	2026-06-05 09:10:42.335	2026-06-05 09:10:42.335	0.1	\N
cmq0pf0yo00bwhk8d03jm6m24	cmpxw9h0j00r6hke6jgtdhnth	29	D	Genel Test	2026-06-05 09:10:42.335	2026-06-05 09:10:42.335	0.1	\N
cmq0pf0yo00bxhk8dy9yr7xpb	cmpxw9h0j00r6hke6jgtdhnth	30	A	Genel Test	2026-06-05 09:10:42.335	2026-06-05 09:10:42.335	0.1	\N
cmq0pf0yo00byhk8d5g0ys1o3	cmpxw9h0j00r6hke6jgtdhnth	31	E	Genel Test	2026-06-05 09:10:42.335	2026-06-05 09:10:42.335	0.1	\N
cmq0pf0yo00bzhk8d4hpddy9e	cmpxw9h0j00r6hke6jgtdhnth	32	D	Genel Test	2026-06-05 09:10:42.335	2026-06-05 09:10:42.335	0.1	\N
cmq0pf0yo00c0hk8dtutr1sv5	cmpxw9h0j00r6hke6jgtdhnth	33	B	Genel Test	2026-06-05 09:10:42.335	2026-06-05 09:10:42.335	0.1	\N
cmq0pf0yo00c1hk8ddlcepfwu	cmpxw9h0j00r6hke6jgtdhnth	34	E	Genel Test	2026-06-05 09:10:42.335	2026-06-05 09:10:42.335	0.1	\N
cmq0pf0yo00c2hk8dnv5qsukn	cmpxw9h0j00r6hke6jgtdhnth	35	A	Genel Test	2026-06-05 09:10:42.335	2026-06-05 09:10:42.335	0.1	\N
cmq0pf0yo00c3hk8d1isxddxd	cmpxw9h0j00r6hke6jgtdhnth	36	E	Genel Test	2026-06-05 09:10:42.335	2026-06-05 09:10:42.335	0.1	\N
cmq0pf0yo00c4hk8ds06e2flv	cmpxw9h0j00r6hke6jgtdhnth	37	E	Genel Test	2026-06-05 09:10:42.335	2026-06-05 09:10:42.335	0.1	\N
cmq0pf0yo00c5hk8dfsam6kdm	cmpxw9h0j00r6hke6jgtdhnth	38	D	Genel Test	2026-06-05 09:10:42.335	2026-06-05 09:10:42.335	0.1	\N
cmq0pf0yo00c6hk8dzgv0qlw2	cmpxw9h0j00r6hke6jgtdhnth	39	C	Genel Test	2026-06-05 09:10:42.335	2026-06-05 09:10:42.335	0.1	\N
cmq0pf0yo00c7hk8d8ti5xeqj	cmpxw9h0j00r6hke6jgtdhnth	40	D	Genel Test	2026-06-05 09:10:42.335	2026-06-05 09:10:42.335	0.1	\N
cmq0pfble00c8hk8d446frwno	cmpxwaxx600sdhke69schfi8y	1	C	Genel Test	2026-06-05 09:10:56.114	2026-06-05 09:10:56.114	0.1	\N
cmq0pfble00c9hk8di76nk4td	cmpxwaxx600sdhke69schfi8y	2	A	Genel Test	2026-06-05 09:10:56.114	2026-06-05 09:10:56.114	0.1	\N
cmq0pfble00cahk8dr7fw1kqh	cmpxwaxx600sdhke69schfi8y	3	C	Genel Test	2026-06-05 09:10:56.114	2026-06-05 09:10:56.114	0.1	\N
cmq0pfble00cbhk8d80cn4rh8	cmpxwaxx600sdhke69schfi8y	4	B	Genel Test	2026-06-05 09:10:56.114	2026-06-05 09:10:56.114	0.1	\N
cmq0pfble00cchk8d4cqw0n2h	cmpxwaxx600sdhke69schfi8y	5	A	Genel Test	2026-06-05 09:10:56.114	2026-06-05 09:10:56.114	0.1	\N
cmq0pfble00cdhk8d1jgwmmzh	cmpxwaxx600sdhke69schfi8y	6	E	Genel Test	2026-06-05 09:10:56.114	2026-06-05 09:10:56.114	0.1	\N
cmq0pfble00cehk8dc9g49vht	cmpxwaxx600sdhke69schfi8y	7	E	Genel Test	2026-06-05 09:10:56.114	2026-06-05 09:10:56.114	0.1	\N
cmq0pfble00cfhk8dp7c6nmnk	cmpxwaxx600sdhke69schfi8y	8	D	Genel Test	2026-06-05 09:10:56.114	2026-06-05 09:10:56.114	0.1	\N
cmq0pfble00cghk8d9s0btw8k	cmpxwaxx600sdhke69schfi8y	9	D	Genel Test	2026-06-05 09:10:56.114	2026-06-05 09:10:56.114	0.1	\N
cmq0pfble00chhk8dn6agbjs7	cmpxwaxx600sdhke69schfi8y	10	E	Genel Test	2026-06-05 09:10:56.114	2026-06-05 09:10:56.114	0.1	\N
cmq0pfble00cihk8d00uum183	cmpxwaxx600sdhke69schfi8y	11	B	Genel Test	2026-06-05 09:10:56.114	2026-06-05 09:10:56.114	0.1	\N
cmq0pfble00cjhk8dm3lu8iut	cmpxwaxx600sdhke69schfi8y	12	D	Genel Test	2026-06-05 09:10:56.114	2026-06-05 09:10:56.114	0.1	\N
cmq0pfble00ckhk8dhvtxggp8	cmpxwaxx600sdhke69schfi8y	13	B	Genel Test	2026-06-05 09:10:56.114	2026-06-05 09:10:56.114	0.1	\N
cmq0pfble00clhk8d8mtndad3	cmpxwaxx600sdhke69schfi8y	14	B	Genel Test	2026-06-05 09:10:56.114	2026-06-05 09:10:56.114	0.1	\N
cmq0pfble00cmhk8d0l7f9xgy	cmpxwaxx600sdhke69schfi8y	15	B	Genel Test	2026-06-05 09:10:56.114	2026-06-05 09:10:56.114	0.1	\N
cmq0pfblf00cnhk8dwlnffx7k	cmpxwaxx600sdhke69schfi8y	16	D	Genel Test	2026-06-05 09:10:56.114	2026-06-05 09:10:56.114	0.1	\N
cmq0pfblf00cohk8dolvhk5yv	cmpxwaxx600sdhke69schfi8y	17	D	Genel Test	2026-06-05 09:10:56.114	2026-06-05 09:10:56.114	0.1	\N
cmq0pfblf00cphk8d280aejj5	cmpxwaxx600sdhke69schfi8y	18	E	Genel Test	2026-06-05 09:10:56.114	2026-06-05 09:10:56.114	0.1	\N
cmq0pfblf00cqhk8ddujaxncq	cmpxwaxx600sdhke69schfi8y	19	B	Genel Test	2026-06-05 09:10:56.114	2026-06-05 09:10:56.114	0.1	\N
cmq0pfblf00crhk8dtyqfghtx	cmpxwaxx600sdhke69schfi8y	20	C	Genel Test	2026-06-05 09:10:56.114	2026-06-05 09:10:56.114	0.1	\N
cmq0pfblf00cshk8d7y6jlm13	cmpxwaxx600sdhke69schfi8y	21	E	Genel Test	2026-06-05 09:10:56.114	2026-06-05 09:10:56.114	0.1	\N
cmq0pfblf00cthk8d0xuwunaj	cmpxwaxx600sdhke69schfi8y	22	D	Genel Test	2026-06-05 09:10:56.114	2026-06-05 09:10:56.114	0.1	\N
cmq0pfblf00cuhk8d2i9vnxls	cmpxwaxx600sdhke69schfi8y	23	C	Genel Test	2026-06-05 09:10:56.114	2026-06-05 09:10:56.114	0.1	\N
cmq0pfblf00cvhk8d9eecex36	cmpxwaxx600sdhke69schfi8y	24	E	Genel Test	2026-06-05 09:10:56.114	2026-06-05 09:10:56.114	0.1	\N
cmq0pfblf00cwhk8d7ti1mtu4	cmpxwaxx600sdhke69schfi8y	25	E	Genel Test	2026-06-05 09:10:56.114	2026-06-05 09:10:56.114	0.1	\N
cmq0pfblf00cxhk8dwpwzdamc	cmpxwaxx600sdhke69schfi8y	26	A	Genel Test	2026-06-05 09:10:56.114	2026-06-05 09:10:56.114	0.1	\N
cmq0pfblf00cyhk8djryb0ims	cmpxwaxx600sdhke69schfi8y	27	E	Genel Test	2026-06-05 09:10:56.114	2026-06-05 09:10:56.114	0.1	\N
cmq0pfblf00czhk8ddnz8pe38	cmpxwaxx600sdhke69schfi8y	28	D	Genel Test	2026-06-05 09:10:56.114	2026-06-05 09:10:56.114	0.1	\N
cmq0pfblf00d0hk8dq9lyig4b	cmpxwaxx600sdhke69schfi8y	29	C	Genel Test	2026-06-05 09:10:56.114	2026-06-05 09:10:56.114	0.1	\N
cmq0pfblf00d1hk8dwz4jvj68	cmpxwaxx600sdhke69schfi8y	30	B	Genel Test	2026-06-05 09:10:56.114	2026-06-05 09:10:56.114	0.1	\N
cmq0pfblf00d2hk8dizdnzk1h	cmpxwaxx600sdhke69schfi8y	31	B	Genel Test	2026-06-05 09:10:56.114	2026-06-05 09:10:56.114	0.1	\N
cmq0pfblf00d3hk8d5nn59446	cmpxwaxx600sdhke69schfi8y	32	B	Genel Test	2026-06-05 09:10:56.114	2026-06-05 09:10:56.114	0.1	\N
cmq0pfblf00d4hk8dtqvf3sfw	cmpxwaxx600sdhke69schfi8y	33	B	Genel Test	2026-06-05 09:10:56.114	2026-06-05 09:10:56.114	0.1	\N
cmq0pfblf00d5hk8dnxk1wuzg	cmpxwaxx600sdhke69schfi8y	34	C	Genel Test	2026-06-05 09:10:56.114	2026-06-05 09:10:56.114	0.1	\N
cmq0pfblf00d6hk8dfmoq0240	cmpxwaxx600sdhke69schfi8y	35	E	Genel Test	2026-06-05 09:10:56.114	2026-06-05 09:10:56.114	0.1	\N
cmq0pfblf00d7hk8dnvi9a0hv	cmpxwaxx600sdhke69schfi8y	36	D	Genel Test	2026-06-05 09:10:56.114	2026-06-05 09:10:56.114	0.1	\N
cmq0pfblf00d8hk8dkzxs03ex	cmpxwaxx600sdhke69schfi8y	37	E	Genel Test	2026-06-05 09:10:56.114	2026-06-05 09:10:56.114	0.1	\N
cmq0pfblf00d9hk8dp9lkr6ga	cmpxwaxx600sdhke69schfi8y	38	B	Genel Test	2026-06-05 09:10:56.114	2026-06-05 09:10:56.114	0.1	\N
cmq0pfblf00dahk8dxhchcsbc	cmpxwaxx600sdhke69schfi8y	39	B	Genel Test	2026-06-05 09:10:56.114	2026-06-05 09:10:56.114	0.1	\N
cmq0pfblf00dbhk8dbpjv1hvq	cmpxwaxx600sdhke69schfi8y	40	C	Genel Test	2026-06-05 09:10:56.114	2026-06-05 09:10:56.114	0.1	\N
cmq0pgghs00hkhk8d1kvayp8i	cmpxw4fdb00ldhke6mjnc94ez	73	E	Genel Kültür	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgghs00hlhk8dmz9sisiq	cmpxw4fdb00ldhke6mjnc94ez	74	E	Genel Kültür	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgghs00hmhk8dc9vk2dzk	cmpxw4fdb00ldhke6mjnc94ez	75	A	Genel Kültür	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgghs00hnhk8dscleebtj	cmpxw4fdb00ldhke6mjnc94ez	76	B	Genel Kültür	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgghs00hohk8dgpo3e10s	cmpxw4fdb00ldhke6mjnc94ez	77	A	Genel Kültür	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgghs00hphk8deame7nxj	cmpxw4fdb00ldhke6mjnc94ez	78	D	Genel Kültür	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgghs00hqhk8d78xqdffn	cmpxw4fdb00ldhke6mjnc94ez	79	C	Genel Kültür	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgghs00hrhk8dl1q9boyb	cmpxw4fdb00ldhke6mjnc94ez	80	E	Genel Kültür	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgghs00hshk8d1hq8bn41	cmpxw4fdb00ldhke6mjnc94ez	81	B	Genel Kültür	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgghs00hthk8d1cwyqjlj	cmpxw4fdb00ldhke6mjnc94ez	82	A	Genel Kültür	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgghs00huhk8dr7kxhizq	cmpxw4fdb00ldhke6mjnc94ez	83	E	Genel Kültür	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgghs00hvhk8dlk83ilsh	cmpxw4fdb00ldhke6mjnc94ez	84	C	Genel Kültür	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgghs00hwhk8dycmjrukm	cmpxw4fdb00ldhke6mjnc94ez	85	E	Genel Kültür	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgghs00hxhk8dzas45lhb	cmpxw4fdb00ldhke6mjnc94ez	86	D	Genel Kültür	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgghs00hyhk8d4r54xd81	cmpxw4fdb00ldhke6mjnc94ez	87	B	Genel Kültür	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgght00hzhk8da40dk2ne	cmpxw4fdb00ldhke6mjnc94ez	88	E	Genel Kültür	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgght00i0hk8d6nypcb1z	cmpxw4fdb00ldhke6mjnc94ez	89	A	Genel Kültür	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgght00i1hk8dq49q4zoi	cmpxw4fdb00ldhke6mjnc94ez	90	C	Genel Kültür	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgght00i2hk8dmw1nra7m	cmpxw4fdb00ldhke6mjnc94ez	91	D	Genel Kültür	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgght00i3hk8d6csj2cp8	cmpxw4fdb00ldhke6mjnc94ez	92	B	Genel Kültür	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgght00i4hk8dsrsw7c9a	cmpxw4fdb00ldhke6mjnc94ez	93	C	Genel Kültür	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgght00i5hk8d6v636kli	cmpxw4fdb00ldhke6mjnc94ez	94	B	Genel Kültür	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgght00i6hk8drsimfvv0	cmpxw4fdb00ldhke6mjnc94ez	95	E	Genel Kültür	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgght00i7hk8dq7jbuo7h	cmpxw4fdb00ldhke6mjnc94ez	96	C	Genel Kültür	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgght00i8hk8dkzdbgfgo	cmpxw4fdb00ldhke6mjnc94ez	97	D	Genel Kültür	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgght00i9hk8d0yyt4fxz	cmpxw4fdb00ldhke6mjnc94ez	98	C	Genel Kültür	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgght00iahk8d2q8lv0i5	cmpxw4fdb00ldhke6mjnc94ez	99	B	Genel Kültür	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgght00ibhk8dgveo6rw5	cmpxw4fdb00ldhke6mjnc94ez	100	C	Genel Kültür	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgght00ichk8dj8nkd2pn	cmpxw4fdb00ldhke6mjnc94ez	101	D	Genel Kültür	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgght00idhk8d0zlq1680	cmpxw4fdb00ldhke6mjnc94ez	102	D	Genel Kültür	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgght00iehk8dqa81dtcu	cmpxw4fdb00ldhke6mjnc94ez	103	B	Genel Kültür	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgght00ifhk8de7q5vssd	cmpxw4fdb00ldhke6mjnc94ez	104	B	Genel Kültür	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pfka300dchk8dcel6wpbo	cmpxw7hz500pzhke6tmzzhqma	1	C	Genel Test	2026-06-05 09:11:07.371	2026-06-05 09:11:07.371	0.1	\N
cmq0pfka400ddhk8dd0yatcvk	cmpxw7hz500pzhke6tmzzhqma	2	B	Genel Test	2026-06-05 09:11:07.371	2026-06-05 09:11:07.371	0.1	\N
cmq0pfka400dehk8dxin7grv9	cmpxw7hz500pzhke6tmzzhqma	3	E	Genel Test	2026-06-05 09:11:07.371	2026-06-05 09:11:07.371	0.1	\N
cmq0pfka400dfhk8drbev3t0t	cmpxw7hz500pzhke6tmzzhqma	4	E	Genel Test	2026-06-05 09:11:07.371	2026-06-05 09:11:07.371	0.1	\N
cmq0pfka400dghk8dfok958am	cmpxw7hz500pzhke6tmzzhqma	5	D	Genel Test	2026-06-05 09:11:07.371	2026-06-05 09:11:07.371	0.1	\N
cmq0pfka400dhhk8d2seihuvx	cmpxw7hz500pzhke6tmzzhqma	6	A	Genel Test	2026-06-05 09:11:07.371	2026-06-05 09:11:07.371	0.1	\N
cmq0pfka400dihk8doakuy70v	cmpxw7hz500pzhke6tmzzhqma	7	A	Genel Test	2026-06-05 09:11:07.371	2026-06-05 09:11:07.371	0.1	\N
cmq0pfka400djhk8danhrw2a9	cmpxw7hz500pzhke6tmzzhqma	8	A	Genel Test	2026-06-05 09:11:07.371	2026-06-05 09:11:07.371	0.1	\N
cmq0pfka400dkhk8dl40zdrn6	cmpxw7hz500pzhke6tmzzhqma	9	C	Genel Test	2026-06-05 09:11:07.371	2026-06-05 09:11:07.371	0.1	\N
cmq0pfka400dlhk8d1hrj7kgo	cmpxw7hz500pzhke6tmzzhqma	10	B	Genel Test	2026-06-05 09:11:07.371	2026-06-05 09:11:07.371	0.1	\N
cmq0pfka400dmhk8d4pullldd	cmpxw7hz500pzhke6tmzzhqma	11	C	Genel Test	2026-06-05 09:11:07.371	2026-06-05 09:11:07.371	0.1	\N
cmq0pkpaj00swhk8du6nnvtio	cmpxu82qi008chke6zpw3f0ll	1	D	Genel Test	2026-06-05 09:15:07.146	2026-06-05 09:15:07.146	0.2	\N
cmq0pkpaj00sxhk8dw5r6xgy8	cmpxu82qi008chke6zpw3f0ll	2	C	Genel Test	2026-06-05 09:15:07.146	2026-06-05 09:15:07.146	0.2	\N
cmq0pkpaj00syhk8dwl80z56u	cmpxu82qi008chke6zpw3f0ll	3	D	Genel Test	2026-06-05 09:15:07.146	2026-06-05 09:15:07.146	0.2	\N
cmq0pkpaj00szhk8dp2we8pev	cmpxu82qi008chke6zpw3f0ll	4	D	Genel Test	2026-06-05 09:15:07.146	2026-06-05 09:15:07.146	0.2	\N
cmq0pkpaj00t0hk8dj0hbt2se	cmpxu82qi008chke6zpw3f0ll	5	E	Genel Test	2026-06-05 09:15:07.146	2026-06-05 09:15:07.146	0.2	\N
cmq0pkpaj00t1hk8da9romhzk	cmpxu82qi008chke6zpw3f0ll	6	A	Genel Test	2026-06-05 09:15:07.146	2026-06-05 09:15:07.146	0.2	\N
cmq0pkpaj00t2hk8dwfnzl7by	cmpxu82qi008chke6zpw3f0ll	7	C	Genel Test	2026-06-05 09:15:07.146	2026-06-05 09:15:07.146	0.2	\N
cmq0pkpaj00t3hk8d7aps4lc4	cmpxu82qi008chke6zpw3f0ll	8	B	Genel Test	2026-06-05 09:15:07.146	2026-06-05 09:15:07.146	0.2	\N
cmq0pkpaj00t4hk8dvjjsy885	cmpxu82qi008chke6zpw3f0ll	9	C	Genel Test	2026-06-05 09:15:07.146	2026-06-05 09:15:07.146	0.2	\N
cmq0pkpaj00t5hk8dz50ywfu4	cmpxu82qi008chke6zpw3f0ll	10	D	Genel Test	2026-06-05 09:15:07.146	2026-06-05 09:15:07.146	0.2	\N
cmq0pkpaj00t6hk8def3y57r7	cmpxu82qi008chke6zpw3f0ll	11	A	Genel Test	2026-06-05 09:15:07.146	2026-06-05 09:15:07.146	0.2	\N
cmq0pkpaj00t7hk8dbra4tcln	cmpxu82qi008chke6zpw3f0ll	12	E	Genel Test	2026-06-05 09:15:07.146	2026-06-05 09:15:07.146	0.2	\N
cmq0pkpaj00t8hk8d2vj3qltz	cmpxu82qi008chke6zpw3f0ll	13	A	Genel Test	2026-06-05 09:15:07.146	2026-06-05 09:15:07.146	0.2	\N
cmq0pkpaj00t9hk8ddqwl2x4w	cmpxu82qi008chke6zpw3f0ll	14	B	Genel Test	2026-06-05 09:15:07.146	2026-06-05 09:15:07.146	0.2	\N
cmq0pkpaj00tahk8da2cdmw6s	cmpxu82qi008chke6zpw3f0ll	15	C	Genel Test	2026-06-05 09:15:07.146	2026-06-05 09:15:07.146	0.2	\N
cmq0pkpaj00tbhk8dpe0yc43f	cmpxu82qi008chke6zpw3f0ll	16	D	Genel Test	2026-06-05 09:15:07.146	2026-06-05 09:15:07.146	0.2	\N
cmq0pkpaj00tchk8d1n6hkuv7	cmpxu82qi008chke6zpw3f0ll	17	E	Genel Test	2026-06-05 09:15:07.146	2026-06-05 09:15:07.146	0.2	\N
cmq0pkpaj00tdhk8dttvy4xb2	cmpxu82qi008chke6zpw3f0ll	18	E	Genel Test	2026-06-05 09:15:07.146	2026-06-05 09:15:07.146	0.2	\N
cmq0pkpaj00tehk8d2fgrob79	cmpxu82qi008chke6zpw3f0ll	19	B	Genel Test	2026-06-05 09:15:07.146	2026-06-05 09:15:07.146	0.2	\N
cmq0pkpaj00tfhk8d4tvzvi9w	cmpxu82qi008chke6zpw3f0ll	20	A	Genel Test	2026-06-05 09:15:07.146	2026-06-05 09:15:07.146	0.2	\N
cmq0pkpaj00tghk8dlqy3u1m0	cmpxu82qi008chke6zpw3f0ll	21	A	Genel Test	2026-06-05 09:15:07.146	2026-06-05 09:15:07.146	0.2	\N
cmq0pkpaj00thhk8ds06vr1ez	cmpxu82qi008chke6zpw3f0ll	22	E	Genel Test	2026-06-05 09:15:07.146	2026-06-05 09:15:07.146	0.2	\N
cmq0pkpaj00tihk8d333rkivl	cmpxu82qi008chke6zpw3f0ll	23	C	Genel Test	2026-06-05 09:15:07.146	2026-06-05 09:15:07.146	0.2	\N
cmq0pkpaj00tjhk8du8luputw	cmpxu82qi008chke6zpw3f0ll	24	E	Genel Test	2026-06-05 09:15:07.146	2026-06-05 09:15:07.146	0.2	\N
cmq0pkpaj00tkhk8dz7dc2tj3	cmpxu82qi008chke6zpw3f0ll	25	B	Genel Test	2026-06-05 09:15:07.146	2026-06-05 09:15:07.146	0.2	\N
cmq0pkpaj00tlhk8dzenn9hr5	cmpxu82qi008chke6zpw3f0ll	26	B	Genel Test	2026-06-05 09:15:07.146	2026-06-05 09:15:07.146	0.2	\N
cmq0pkpaj00tmhk8dl49pd6am	cmpxu82qi008chke6zpw3f0ll	27	C	Genel Test	2026-06-05 09:15:07.146	2026-06-05 09:15:07.146	0.2	\N
cmq0pkpak00tnhk8dm3ghcnip	cmpxu82qi008chke6zpw3f0ll	28	C	Genel Test	2026-06-05 09:15:07.146	2026-06-05 09:15:07.146	0.2	\N
cmq0pkpak00tohk8dytmy9n3r	cmpxu82qi008chke6zpw3f0ll	29	E	Genel Test	2026-06-05 09:15:07.146	2026-06-05 09:15:07.146	0.2	\N
cmq0pkpak00tphk8dtbruarx4	cmpxu82qi008chke6zpw3f0ll	30	D	Genel Test	2026-06-05 09:15:07.146	2026-06-05 09:15:07.146	0.2	\N
cmq0pkpak00tqhk8djmb0j7px	cmpxu82qi008chke6zpw3f0ll	31	C	Genel Test	2026-06-05 09:15:07.146	2026-06-05 09:15:07.146	0.2	\N
cmq0pkpak00trhk8d7etpb0cy	cmpxu82qi008chke6zpw3f0ll	32	D	Genel Test	2026-06-05 09:15:07.146	2026-06-05 09:15:07.146	0.2	\N
cmq0pkpak00tshk8desrok25u	cmpxu82qi008chke6zpw3f0ll	33	D	Genel Test	2026-06-05 09:15:07.146	2026-06-05 09:15:07.146	0.2	\N
cmq0qaxm501cxhk8dotsbbijq	cmpfka7qt01xqhkzbwuyum22o	42	E	Genel Yetenek	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm501cyhk8dvq23llj6	cmpfka7qt01xqhkzbwuyum22o	43	C	Genel Yetenek	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm501czhk8dxsstv0f2	cmpfka7qt01xqhkzbwuyum22o	44	E	Genel Yetenek	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm501d0hk8du7zeigst	cmpfka7qt01xqhkzbwuyum22o	45	C	Genel Yetenek	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm501d1hk8d8d8jtx8v	cmpfka7qt01xqhkzbwuyum22o	46	C	Genel Yetenek	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm501d2hk8d9olwalfm	cmpfka7qt01xqhkzbwuyum22o	47	D	Genel Yetenek	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm501d3hk8dwlyqnnw2	cmpfka7qt01xqhkzbwuyum22o	48	A	Genel Yetenek	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm501d4hk8doeglp2fs	cmpfka7qt01xqhkzbwuyum22o	49	A	Genel Yetenek	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm501d5hk8derzz6mk9	cmpfka7qt01xqhkzbwuyum22o	50	A	Genel Yetenek	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm501d6hk8d8gruv47t	cmpfka7qt01xqhkzbwuyum22o	51	A	Genel Yetenek	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm501d7hk8dazvo98tc	cmpfka7qt01xqhkzbwuyum22o	52	B	Genel Yetenek	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm501d8hk8dorzt3f4h	cmpfka7qt01xqhkzbwuyum22o	53	C	Genel Yetenek	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm601d9hk8dqtwgfqk8	cmpfka7qt01xqhkzbwuyum22o	54	B	Genel Yetenek	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm601dahk8d3vktdxzz	cmpfka7qt01xqhkzbwuyum22o	55	D	Genel Yetenek	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm601dbhk8drcyhae22	cmpfka7qt01xqhkzbwuyum22o	56	A	Genel Yetenek	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm601dchk8dyxni61xr	cmpfka7qt01xqhkzbwuyum22o	57	C	Genel Yetenek	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm601ddhk8dfyez1wol	cmpfka7qt01xqhkzbwuyum22o	58	C	Genel Yetenek	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0pkpak00tthk8dxtpx7wg3	cmpxu82qi008chke6zpw3f0ll	34	D	Genel Test	2026-06-05 09:15:07.146	2026-06-05 09:15:07.146	0.2	\N
cmpzk9m0a00b4hk8cpzreew8r	cmpgmklqk0002hk9karfvcygv	41	A	Genel Yetenek	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0a00b5hk8cgjxdd9yj	cmpgmklqk0002hk9karfvcygv	42	E	Genel Yetenek	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0a00b6hk8cjg6l55xz	cmpgmklqk0002hk9karfvcygv	43	A	Genel Yetenek	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0a00b7hk8cr8sq2op0	cmpgmklqk0002hk9karfvcygv	44	C	Genel Yetenek	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0a00b8hk8cnyzaneah	cmpgmklqk0002hk9karfvcygv	45	E	Genel Yetenek	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0a00b9hk8c997rko8h	cmpgmklqk0002hk9karfvcygv	46	B	Genel Yetenek	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0a00bahk8c8eqgt5l9	cmpgmklqk0002hk9karfvcygv	47	C	Genel Yetenek	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0a00bbhk8cq5vtbtw9	cmpgmklqk0002hk9karfvcygv	48	A	Genel Yetenek	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0a00bchk8c3lx2o8nf	cmpgmklqk0002hk9karfvcygv	49	E	Genel Yetenek	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0a00bdhk8cwlo9gqbu	cmpgmklqk0002hk9karfvcygv	50	B	Genel Yetenek	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0a00behk8cb3whlat3	cmpgmklqk0002hk9karfvcygv	51	A	Genel Yetenek	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0a00bfhk8cgoegccp3	cmpgmklqk0002hk9karfvcygv	52	C	Genel Yetenek	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0a00bghk8cr1jt59xv	cmpgmklqk0002hk9karfvcygv	53	A	Genel Yetenek	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0a00bhhk8cpknhh1yk	cmpgmklqk0002hk9karfvcygv	54	B	Genel Yetenek	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0a00bihk8c166ffr1o	cmpgmklqk0002hk9karfvcygv	55	D	Genel Yetenek	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0a00bjhk8c4hhv1rza	cmpgmklqk0002hk9karfvcygv	56	E	Genel Yetenek	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0a00bkhk8cf0y0qjm6	cmpgmklqk0002hk9karfvcygv	57	E	Genel Yetenek	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0a00blhk8c9mr52o3u	cmpgmklqk0002hk9karfvcygv	58	A	Genel Yetenek	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0a00bmhk8cbllx6ip6	cmpgmklqk0002hk9karfvcygv	59	B	Genel Yetenek	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0a00bnhk8ccme4wlph	cmpgmklqk0002hk9karfvcygv	60	C	Genel Yetenek	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0a00bohk8czz9eem4r	cmpgmklqk0002hk9karfvcygv	61	E	Genel Kültür	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0a00bphk8cb0u9uda9	cmpgmklqk0002hk9karfvcygv	62	E	Genel Kültür	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0a00bqhk8cln7zsepo	cmpgmklqk0002hk9karfvcygv	63	B	Genel Kültür	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0a00brhk8crm8d9cl8	cmpgmklqk0002hk9karfvcygv	64	E	Genel Kültür	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0a00bshk8cvav3frap	cmpgmklqk0002hk9karfvcygv	65	A	Genel Kültür	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0a00bthk8cyzzril0b	cmpgmklqk0002hk9karfvcygv	66	C	Genel Kültür	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0a00buhk8cl9ji7luy	cmpgmklqk0002hk9karfvcygv	67	C	Genel Kültür	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0a00bvhk8cvhwoaubd	cmpgmklqk0002hk9karfvcygv	68	C	Genel Kültür	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0b00bwhk8cc6fbqn49	cmpgmklqk0002hk9karfvcygv	69	E	Genel Kültür	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0b00bxhk8c5smn9gif	cmpgmklqk0002hk9karfvcygv	70	B	Genel Kültür	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0b00byhk8ckqvuc8zt	cmpgmklqk0002hk9karfvcygv	71	E	Genel Kültür	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0b00bzhk8cddz26kal	cmpgmklqk0002hk9karfvcygv	72	A	Genel Kültür	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0b00c0hk8cs4rrwxv0	cmpgmklqk0002hk9karfvcygv	73	E	Genel Kültür	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0b00c1hk8ck71q5gor	cmpgmklqk0002hk9karfvcygv	74	C	Genel Kültür	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0b00c2hk8chk9we3h9	cmpgmklqk0002hk9karfvcygv	75	B	Genel Kültür	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0b00c3hk8csdgsw5ql	cmpgmklqk0002hk9karfvcygv	76	A	Genel Kültür	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0b00c4hk8cm6qmpr2a	cmpgmklqk0002hk9karfvcygv	77	B	Genel Kültür	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0b00c5hk8c6k65u4u5	cmpgmklqk0002hk9karfvcygv	78	D	Genel Kültür	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0b00c6hk8c6t6m79f3	cmpgmklqk0002hk9karfvcygv	79	B	Genel Kültür	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0b00c7hk8ca30sxs56	cmpgmklqk0002hk9karfvcygv	80	C	Genel Kültür	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0b00c8hk8cof4yitr0	cmpgmklqk0002hk9karfvcygv	81	C	Genel Kültür	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0b00c9hk8cpnopi0yk	cmpgmklqk0002hk9karfvcygv	82	D	Genel Kültür	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0b00cahk8c6czqrcas	cmpgmklqk0002hk9karfvcygv	83	A	Genel Kültür	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0b00cbhk8clhqk6q6y	cmpgmklqk0002hk9karfvcygv	84	D	Genel Kültür	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0b00cchk8c6eqxsjjh	cmpgmklqk0002hk9karfvcygv	85	C	Genel Kültür	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0b00cdhk8cdnv8ho9h	cmpgmklqk0002hk9karfvcygv	86	D	Genel Kültür	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0b00cehk8cmfpagmzj	cmpgmklqk0002hk9karfvcygv	87	A	Genel Kültür	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0b00cfhk8chkc7a0l3	cmpgmklqk0002hk9karfvcygv	88	C	Genel Kültür	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0b00cghk8can8ubd92	cmpgmklqk0002hk9karfvcygv	89	C	Genel Kültür	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0b00chhk8c11ty290r	cmpgmklqk0002hk9karfvcygv	90	C	Genel Kültür	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0b00cihk8cm78hwi1p	cmpgmklqk0002hk9karfvcygv	91	D	Genel Kültür	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0b00cjhk8ckwzsylu7	cmpgmklqk0002hk9karfvcygv	92	A	Genel Kültür	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0b00ckhk8ce7lpsvzz	cmpgmklqk0002hk9karfvcygv	93	D	Genel Kültür	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmq0pkpak00tuhk8dwwvcq290	cmpxu82qi008chke6zpw3f0ll	35	A	Genel Test	2026-06-05 09:15:07.146	2026-06-05 09:15:07.146	0.2	\N
cmq0pkpak00tvhk8didie7vha	cmpxu82qi008chke6zpw3f0ll	36	D	Genel Test	2026-06-05 09:15:07.146	2026-06-05 09:15:07.146	0.2	\N
cmq0pkpak00twhk8d5rodqav7	cmpxu82qi008chke6zpw3f0ll	37	A	Genel Test	2026-06-05 09:15:07.146	2026-06-05 09:15:07.146	0.2	\N
cmq0pkpak00txhk8d673f23c1	cmpxu82qi008chke6zpw3f0ll	38	B	Genel Test	2026-06-05 09:15:07.146	2026-06-05 09:15:07.146	0.2	\N
cmq0pkpak00tyhk8drlpgcxr0	cmpxu82qi008chke6zpw3f0ll	39	C	Genel Test	2026-06-05 09:15:07.146	2026-06-05 09:15:07.146	0.2	\N
cmpzjoqx00000hk8ccnc9s5al	cmpfbgd4j0002hkzbbn0o1dlo	1	E	Genel Yetenek	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx00001hk8c7izktr6w	cmpfbgd4j0002hkzbbn0o1dlo	2	D	Genel Yetenek	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx00002hk8ci707qelm	cmpfbgd4j0002hkzbbn0o1dlo	3	D	Genel Yetenek	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx00003hk8coq9ointo	cmpfbgd4j0002hkzbbn0o1dlo	4	E	Genel Yetenek	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx00004hk8cqay5swos	cmpfbgd4j0002hkzbbn0o1dlo	5	E	Genel Yetenek	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx00005hk8cldtam4wn	cmpfbgd4j0002hkzbbn0o1dlo	6	A	Genel Yetenek	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx00006hk8cfi9e0eyv	cmpfbgd4j0002hkzbbn0o1dlo	7	C	Genel Yetenek	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx00007hk8cenhm6j3y	cmpfbgd4j0002hkzbbn0o1dlo	8	B	Genel Yetenek	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx00008hk8c33vhr3zy	cmpfbgd4j0002hkzbbn0o1dlo	9	D	Genel Yetenek	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx00009hk8c45kalg76	cmpfbgd4j0002hkzbbn0o1dlo	10	D	Genel Yetenek	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx0000ahk8c7v9kwl8b	cmpfbgd4j0002hkzbbn0o1dlo	11	A	Genel Yetenek	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx0000bhk8cfbfop5rd	cmpfbgd4j0002hkzbbn0o1dlo	12	B	Genel Yetenek	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx0000chk8cl0jxuplc	cmpfbgd4j0002hkzbbn0o1dlo	13	B	Genel Yetenek	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx1000dhk8c0yd6eriy	cmpfbgd4j0002hkzbbn0o1dlo	14	A	Genel Yetenek	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx1000ehk8ctiw4m3d7	cmpfbgd4j0002hkzbbn0o1dlo	15	C	Genel Yetenek	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx1000fhk8c7bx5yv2g	cmpfbgd4j0002hkzbbn0o1dlo	16	D	Genel Yetenek	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx1000ghk8c99qkya94	cmpfbgd4j0002hkzbbn0o1dlo	17	E	Genel Yetenek	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx1000hhk8coa2kdg0c	cmpfbgd4j0002hkzbbn0o1dlo	18	A	Genel Yetenek	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx1000ihk8csq3py3c3	cmpfbgd4j0002hkzbbn0o1dlo	19	C	Genel Yetenek	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx1000jhk8cjqaaogks	cmpfbgd4j0002hkzbbn0o1dlo	20	A	Genel Yetenek	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx1000khk8cj1y9tkdz	cmpfbgd4j0002hkzbbn0o1dlo	21	A	Genel Yetenek	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx1000lhk8ch25sgesg	cmpfbgd4j0002hkzbbn0o1dlo	22	B	Genel Yetenek	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx1000mhk8cxa7rxu84	cmpfbgd4j0002hkzbbn0o1dlo	23	B	Genel Yetenek	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx1000nhk8cl6begelj	cmpfbgd4j0002hkzbbn0o1dlo	24	D	Genel Yetenek	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx1000ohk8cbug8qtq9	cmpfbgd4j0002hkzbbn0o1dlo	25	A	Genel Yetenek	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx1000phk8ca099fg96	cmpfbgd4j0002hkzbbn0o1dlo	26	C	Genel Yetenek	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx1000qhk8cm4g53pmn	cmpfbgd4j0002hkzbbn0o1dlo	27	C	Genel Yetenek	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx1000rhk8cjt910zrh	cmpfbgd4j0002hkzbbn0o1dlo	28	D	Genel Yetenek	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx2000shk8c69y5sgss	cmpfbgd4j0002hkzbbn0o1dlo	29	B	Genel Yetenek	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx2000thk8c5fqt6bo4	cmpfbgd4j0002hkzbbn0o1dlo	30	A	Genel Yetenek	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx2000uhk8cw4hbomn5	cmpfbgd4j0002hkzbbn0o1dlo	31	B	Genel Yetenek	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx2000vhk8c5p2ycdcq	cmpfbgd4j0002hkzbbn0o1dlo	32	E	Genel Yetenek	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx2000whk8c823iwotl	cmpfbgd4j0002hkzbbn0o1dlo	33	A	Genel Yetenek	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx2000xhk8ccjvg1855	cmpfbgd4j0002hkzbbn0o1dlo	34	D	Genel Yetenek	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx2000yhk8cglxw8tzy	cmpfbgd4j0002hkzbbn0o1dlo	35	A	Genel Yetenek	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx2000zhk8c2r7p2n3b	cmpfbgd4j0002hkzbbn0o1dlo	36	A	Genel Yetenek	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx20010hk8c88xks2qv	cmpfbgd4j0002hkzbbn0o1dlo	37	B	Genel Yetenek	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx20011hk8cp6h673zb	cmpfbgd4j0002hkzbbn0o1dlo	38	A	Genel Yetenek	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx20012hk8c4bmmipaa	cmpfbgd4j0002hkzbbn0o1dlo	39	B	Genel Yetenek	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx20013hk8cs1bkr2jb	cmpfbgd4j0002hkzbbn0o1dlo	40	A	Genel Yetenek	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx20014hk8cfi65u5jx	cmpfbgd4j0002hkzbbn0o1dlo	41	C	Genel Yetenek	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx20015hk8cdz529r4q	cmpfbgd4j0002hkzbbn0o1dlo	42	A	Genel Yetenek	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx20016hk8cwt2uual2	cmpfbgd4j0002hkzbbn0o1dlo	43	E	Genel Yetenek	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx20017hk8crqod48l2	cmpfbgd4j0002hkzbbn0o1dlo	44	B	Genel Yetenek	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx30018hk8cxmtd5z4s	cmpfbgd4j0002hkzbbn0o1dlo	45	C	Genel Yetenek	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx30019hk8ciecwfq8l	cmpfbgd4j0002hkzbbn0o1dlo	46	A	Genel Yetenek	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx3001ahk8cgglqqkad	cmpfbgd4j0002hkzbbn0o1dlo	47	E	Genel Yetenek	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx3001bhk8coxq8kjuo	cmpfbgd4j0002hkzbbn0o1dlo	48	D	Genel Yetenek	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx3001chk8cq8cx7qe5	cmpfbgd4j0002hkzbbn0o1dlo	49	B	Genel Yetenek	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx3001dhk8c3t5nuztw	cmpfbgd4j0002hkzbbn0o1dlo	50	A	Genel Yetenek	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx3001ehk8chi1g0swt	cmpfbgd4j0002hkzbbn0o1dlo	51	E	Genel Yetenek	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx3001fhk8cdy73piia	cmpfbgd4j0002hkzbbn0o1dlo	52	B	Genel Yetenek	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx3001ghk8cu0ddb8cy	cmpfbgd4j0002hkzbbn0o1dlo	53	D	Genel Yetenek	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx3001hhk8c05sqdcbv	cmpfbgd4j0002hkzbbn0o1dlo	54	C	Genel Yetenek	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx3001ihk8ctrfn6di9	cmpfbgd4j0002hkzbbn0o1dlo	55	A	Genel Yetenek	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx3001jhk8cb7ncu0cf	cmpfbgd4j0002hkzbbn0o1dlo	56	A	Genel Yetenek	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx3001khk8cnbpxh1e1	cmpfbgd4j0002hkzbbn0o1dlo	57	D	Genel Yetenek	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx3001lhk8c8cvcl613	cmpfbgd4j0002hkzbbn0o1dlo	58	A	Genel Yetenek	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx3001mhk8c1xak9s2v	cmpfbgd4j0002hkzbbn0o1dlo	59	A	Genel Yetenek	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx3001nhk8cxzpod43g	cmpfbgd4j0002hkzbbn0o1dlo	60	B	Genel Yetenek	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx4001ohk8cqqq5fwhz	cmpfbgd4j0002hkzbbn0o1dlo	61	C	Genel Kültür	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx4001phk8clyiqrann	cmpfbgd4j0002hkzbbn0o1dlo	62	C	Genel Kültür	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx4001qhk8copwtvefm	cmpfbgd4j0002hkzbbn0o1dlo	63	A	Genel Kültür	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx4001rhk8cb1ekngqv	cmpfbgd4j0002hkzbbn0o1dlo	64	A	Genel Kültür	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx4001shk8ciebgzbdv	cmpfbgd4j0002hkzbbn0o1dlo	65	A	Genel Kültür	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx4001thk8cpq1dykt1	cmpfbgd4j0002hkzbbn0o1dlo	66	E	Genel Kültür	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx4001uhk8codifmtve	cmpfbgd4j0002hkzbbn0o1dlo	67	A	Genel Kültür	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx4001vhk8cnai1mnuu	cmpfbgd4j0002hkzbbn0o1dlo	68	C	Genel Kültür	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx4001whk8cja2q0pxo	cmpfbgd4j0002hkzbbn0o1dlo	69	B	Genel Kültür	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx4001xhk8c5fvmpfyo	cmpfbgd4j0002hkzbbn0o1dlo	70	C	Genel Kültür	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx4001yhk8cbl6iu9n5	cmpfbgd4j0002hkzbbn0o1dlo	71	B	Genel Kültür	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx4001zhk8cpzmy4jee	cmpfbgd4j0002hkzbbn0o1dlo	72	B	Genel Kültür	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx40020hk8coa0jedk0	cmpfbgd4j0002hkzbbn0o1dlo	73	A	Genel Kültür	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx40021hk8coxcxi9u3	cmpfbgd4j0002hkzbbn0o1dlo	74	D	Genel Kültür	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx40022hk8cu1350av8	cmpfbgd4j0002hkzbbn0o1dlo	75	D	Genel Kültür	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx50023hk8clr2l77o3	cmpfbgd4j0002hkzbbn0o1dlo	76	E	Genel Kültür	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx50024hk8cybj9qg5y	cmpfbgd4j0002hkzbbn0o1dlo	77	A	Genel Kültür	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx50025hk8cm3l3wflu	cmpfbgd4j0002hkzbbn0o1dlo	78	B	Genel Kültür	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx50026hk8cqfem68f9	cmpfbgd4j0002hkzbbn0o1dlo	79	E	Genel Kültür	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx50027hk8c3vcl9iky	cmpfbgd4j0002hkzbbn0o1dlo	80	C	Genel Kültür	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx50028hk8ca2htwmyk	cmpfbgd4j0002hkzbbn0o1dlo	81	D	Genel Kültür	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx50029hk8cu4k7cngd	cmpfbgd4j0002hkzbbn0o1dlo	82	B	Genel Kültür	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx5002ahk8cw8vgnn2b	cmpfbgd4j0002hkzbbn0o1dlo	83	C	Genel Kültür	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx5002bhk8cowszc5f0	cmpfbgd4j0002hkzbbn0o1dlo	84	A	Genel Kültür	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx5002chk8czvind2sb	cmpfbgd4j0002hkzbbn0o1dlo	85	A	Genel Kültür	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx5002dhk8ceksn54rm	cmpfbgd4j0002hkzbbn0o1dlo	86	B	Genel Kültür	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx5002ehk8c8w3hs3a6	cmpfbgd4j0002hkzbbn0o1dlo	87	C	Genel Kültür	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx5002fhk8c6ayb492g	cmpfbgd4j0002hkzbbn0o1dlo	88	A	Genel Kültür	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx5002ghk8c5hcd801t	cmpfbgd4j0002hkzbbn0o1dlo	89	B	Genel Kültür	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx5002hhk8cdkyl87sg	cmpfbgd4j0002hkzbbn0o1dlo	90	B	Genel Kültür	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx5002ihk8cyrh396xj	cmpfbgd4j0002hkzbbn0o1dlo	91	C	Genel Kültür	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx6002jhk8cnzzjkyig	cmpfbgd4j0002hkzbbn0o1dlo	92	D	Genel Kültür	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx6002khk8cip1oyq7t	cmpfbgd4j0002hkzbbn0o1dlo	93	D	Genel Kültür	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx6002lhk8cnehc0vuo	cmpfbgd4j0002hkzbbn0o1dlo	94	B	Genel Kültür	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx6002mhk8cgkin99fr	cmpfbgd4j0002hkzbbn0o1dlo	95	A	Genel Kültür	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx6002nhk8cpe6pnlnk	cmpfbgd4j0002hkzbbn0o1dlo	96	C	Genel Kültür	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx6002ohk8cfhs4079o	cmpfbgd4j0002hkzbbn0o1dlo	97	E	Genel Kültür	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx6002phk8c2qs17x76	cmpfbgd4j0002hkzbbn0o1dlo	98	D	Genel Kültür	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx6002qhk8cvn1yhif6	cmpfbgd4j0002hkzbbn0o1dlo	99	A	Genel Kültür	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx6002rhk8c1y9pc8x7	cmpfbgd4j0002hkzbbn0o1dlo	100	A	Genel Kültür	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx6002shk8cmcbwktbe	cmpfbgd4j0002hkzbbn0o1dlo	101	E	Genel Kültür	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx6002thk8cax7nbxva	cmpfbgd4j0002hkzbbn0o1dlo	102	A	Genel Kültür	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx6002uhk8cq3k3aot2	cmpfbgd4j0002hkzbbn0o1dlo	103	E	Genel Kültür	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx6002vhk8cqkovzdbp	cmpfbgd4j0002hkzbbn0o1dlo	104	E	Genel Kültür	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx6002whk8cazz3k5wj	cmpfbgd4j0002hkzbbn0o1dlo	105	B	Genel Kültür	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx6002xhk8cl6ve2rgn	cmpfbgd4j0002hkzbbn0o1dlo	106	D	Genel Kültür	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx6002yhk8cdjhvmpvj	cmpfbgd4j0002hkzbbn0o1dlo	107	C	Genel Kültür	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx7002zhk8ctl2ld32g	cmpfbgd4j0002hkzbbn0o1dlo	108	C	Genel Kültür	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx70030hk8ccmxk8pe8	cmpfbgd4j0002hkzbbn0o1dlo	109	B	Genel Kültür	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx70031hk8c02d8x2vo	cmpfbgd4j0002hkzbbn0o1dlo	110	D	Genel Kültür	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx70032hk8c8aegbpc3	cmpfbgd4j0002hkzbbn0o1dlo	111	C	Genel Kültür	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx70033hk8c8y0m8bhr	cmpfbgd4j0002hkzbbn0o1dlo	112	E	Genel Kültür	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx70034hk8cg52lsoc7	cmpfbgd4j0002hkzbbn0o1dlo	113	A	Genel Kültür	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx70035hk8cc67g0pku	cmpfbgd4j0002hkzbbn0o1dlo	114	D	Genel Kültür	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx70036hk8c44b1wm3b	cmpfbgd4j0002hkzbbn0o1dlo	115	C	Genel Kültür	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx70037hk8c4t176toa	cmpfbgd4j0002hkzbbn0o1dlo	116	B	Genel Kültür	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx70038hk8clxz9qrxw	cmpfbgd4j0002hkzbbn0o1dlo	117	D	Genel Kültür	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx70039hk8crl0q0uce	cmpfbgd4j0002hkzbbn0o1dlo	118	B	Genel Kültür	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx7003ahk8cqnopr3lb	cmpfbgd4j0002hkzbbn0o1dlo	119	C	Genel Kültür	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzjoqx7003bhk8cxyadwhph	cmpfbgd4j0002hkzbbn0o1dlo	120	B	Genel Kültür	2026-06-04 13:42:32.001	2026-06-04 13:42:32.001	0.1	\N
cmpzk9m0b00clhk8cp114w3qe	cmpgmklqk0002hk9karfvcygv	94	D	Genel Kültür	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0b00cmhk8ck2g8o157	cmpgmklqk0002hk9karfvcygv	95	C	Genel Kültür	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0b00cnhk8cphwcrb29	cmpgmklqk0002hk9karfvcygv	96	C	Genel Kültür	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0b00cohk8cyukfvlfy	cmpgmklqk0002hk9karfvcygv	97	D	Genel Kültür	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0b00cphk8csb1egtqq	cmpgmklqk0002hk9karfvcygv	98	C	Genel Kültür	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0b00cqhk8c77dbvbxs	cmpgmklqk0002hk9karfvcygv	99	A	Genel Kültür	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0b00crhk8cn5rjykdp	cmpgmklqk0002hk9karfvcygv	100	B	Genel Kültür	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0b00cshk8cjghd1od4	cmpgmklqk0002hk9karfvcygv	101	D	Genel Kültür	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0c00cthk8ct6u3ri8p	cmpgmklqk0002hk9karfvcygv	102	D	Genel Kültür	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0c00cuhk8c39dh7386	cmpgmklqk0002hk9karfvcygv	103	B	Genel Kültür	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0c00cvhk8c0xsfdb9z	cmpgmklqk0002hk9karfvcygv	104	A	Genel Kültür	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0c00cwhk8c937knw2e	cmpgmklqk0002hk9karfvcygv	105	E	Genel Kültür	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0c00cxhk8c8il0ci0b	cmpgmklqk0002hk9karfvcygv	106	D	Genel Kültür	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0c00cyhk8cuw1e04ux	cmpgmklqk0002hk9karfvcygv	107	A	Genel Kültür	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0c00czhk8c0ok9t6p7	cmpgmklqk0002hk9karfvcygv	108	C	Genel Kültür	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0c00d0hk8c4dc2i8so	cmpgmklqk0002hk9karfvcygv	109	E	Genel Kültür	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0c00d1hk8cbtb2kytb	cmpgmklqk0002hk9karfvcygv	110	A	Genel Kültür	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0c00d2hk8cx19tg1o9	cmpgmklqk0002hk9karfvcygv	111	C	Genel Kültür	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0c00d3hk8cmrgl1ohv	cmpgmklqk0002hk9karfvcygv	112	E	Genel Kültür	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0c00d4hk8ct6rniuu2	cmpgmklqk0002hk9karfvcygv	113	D	Genel Kültür	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0c00d5hk8c1ya4bx3m	cmpgmklqk0002hk9karfvcygv	114	B	Genel Kültür	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0c00d6hk8cq29fzmu7	cmpgmklqk0002hk9karfvcygv	115	B	Genel Kültür	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0c00d7hk8c580hsk3k	cmpgmklqk0002hk9karfvcygv	116	A	Genel Kültür	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0c00d8hk8cfzalv4fi	cmpgmklqk0002hk9karfvcygv	117	E	Genel Kültür	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0c00d9hk8c6j7a4axm	cmpgmklqk0002hk9karfvcygv	118	B	Genel Kültür	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0c00dahk8c5qt7bmjs	cmpgmklqk0002hk9karfvcygv	119	A	Genel Kültür	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0c00dbhk8ccd3mdwdl	cmpgmklqk0002hk9karfvcygv	120	D	Genel Kültür	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzkdjo300fmhk8c1sh4sa6a	cmpwswxce0002hkwpttlr7zwx	83	B	Genel Kültür	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo300fnhk8cj798og2e	cmpwswxce0002hkwpttlr7zwx	84	D	Genel Kültür	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo300fohk8cws401i8d	cmpwswxce0002hkwpttlr7zwx	85	D	Genel Kültür	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo300fphk8cfu3royao	cmpwswxce0002hkwpttlr7zwx	86	E	Genel Kültür	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo300fqhk8ci8tik9kb	cmpwswxce0002hkwpttlr7zwx	87	E	Genel Kültür	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo300frhk8coxufdxnh	cmpwswxce0002hkwpttlr7zwx	88	C	Genel Kültür	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo300fshk8cfsjrsybt	cmpwswxce0002hkwpttlr7zwx	89	D	Genel Kültür	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo300fthk8cu080z1je	cmpwswxce0002hkwpttlr7zwx	90	A	Genel Kültür	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo300fuhk8c6bok4ej8	cmpwswxce0002hkwpttlr7zwx	91	C	Genel Kültür	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo300fvhk8cjrlyfr2v	cmpwswxce0002hkwpttlr7zwx	92	D	Genel Kültür	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo300fwhk8ct5lxiolb	cmpwswxce0002hkwpttlr7zwx	93	C	Genel Kültür	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo300fxhk8c7zv4xyil	cmpwswxce0002hkwpttlr7zwx	94	D	Genel Kültür	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo300fyhk8cluvkljqx	cmpwswxce0002hkwpttlr7zwx	95	E	Genel Kültür	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo300fzhk8cslwhgt2x	cmpwswxce0002hkwpttlr7zwx	96	D	Genel Kültür	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo300g0hk8cx97den9i	cmpwswxce0002hkwpttlr7zwx	97	C	Genel Kültür	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo300g1hk8cow5uk9wp	cmpwswxce0002hkwpttlr7zwx	98	A	Genel Kültür	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo300g2hk8cejwhmh01	cmpwswxce0002hkwpttlr7zwx	99	A	Genel Kültür	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo300g3hk8cs90yepy3	cmpwswxce0002hkwpttlr7zwx	100	E	Genel Kültür	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo300g4hk8ctxgpkj2a	cmpwswxce0002hkwpttlr7zwx	101	E	Genel Kültür	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo300g5hk8csrljixqn	cmpwswxce0002hkwpttlr7zwx	102	C	Genel Kültür	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo400g6hk8c9ld3bebq	cmpwswxce0002hkwpttlr7zwx	103	D	Genel Kültür	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo400g7hk8cmdpvlzda	cmpwswxce0002hkwpttlr7zwx	104	B	Genel Kültür	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo400g8hk8cxb285fae	cmpwswxce0002hkwpttlr7zwx	105	E	Genel Kültür	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo400g9hk8cij66h1vl	cmpwswxce0002hkwpttlr7zwx	106	B	Genel Kültür	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo400gahk8cuqlem5to	cmpwswxce0002hkwpttlr7zwx	107	A	Genel Kültür	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo400gbhk8c5qm94a1l	cmpwswxce0002hkwpttlr7zwx	108	B	Genel Kültür	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo400gchk8ctp5mse2u	cmpwswxce0002hkwpttlr7zwx	109	C	Genel Kültür	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo400gdhk8c02n5yexm	cmpwswxce0002hkwpttlr7zwx	110	A	Genel Kültür	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo400gehk8cm0p8nl1e	cmpwswxce0002hkwpttlr7zwx	111	C	Genel Kültür	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo400gfhk8c066qwcnj	cmpwswxce0002hkwpttlr7zwx	112	C	Genel Kültür	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzjy4p2003chk8caomikdmd	cmpfexe0c01puhkzb3pkg2qkg	1	B	Genel Yetenek	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p2003dhk8c9mh8molw	cmpfexe0c01puhkzb3pkg2qkg	2	D	Genel Yetenek	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p2003ehk8cua652963	cmpfexe0c01puhkzb3pkg2qkg	3	C	Genel Yetenek	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p2003fhk8cqe46kdw7	cmpfexe0c01puhkzb3pkg2qkg	4	A	Genel Yetenek	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p2003ghk8cr7osq8xg	cmpfexe0c01puhkzb3pkg2qkg	5	A	Genel Yetenek	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p2003hhk8cvojzlwet	cmpfexe0c01puhkzb3pkg2qkg	6	C	Genel Yetenek	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p2003ihk8cup4vbbaj	cmpfexe0c01puhkzb3pkg2qkg	7	B	Genel Yetenek	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p2003jhk8c8u9huo9h	cmpfexe0c01puhkzb3pkg2qkg	8	E	Genel Yetenek	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p2003khk8cvsdaru6e	cmpfexe0c01puhkzb3pkg2qkg	9	E	Genel Yetenek	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p2003lhk8chg0rfj3s	cmpfexe0c01puhkzb3pkg2qkg	10	A	Genel Yetenek	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p2003mhk8c118mao48	cmpfexe0c01puhkzb3pkg2qkg	11	C	Genel Yetenek	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p2003nhk8cymromsni	cmpfexe0c01puhkzb3pkg2qkg	12	D	Genel Yetenek	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p2003ohk8cr25md63q	cmpfexe0c01puhkzb3pkg2qkg	13	A	Genel Yetenek	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p2003phk8c4bal9t13	cmpfexe0c01puhkzb3pkg2qkg	14	B	Genel Yetenek	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p2003qhk8culbnzweo	cmpfexe0c01puhkzb3pkg2qkg	15	B	Genel Yetenek	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p2003rhk8chir3rkrp	cmpfexe0c01puhkzb3pkg2qkg	16	D	Genel Yetenek	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p2003shk8caqsn1zmd	cmpfexe0c01puhkzb3pkg2qkg	17	C	Genel Yetenek	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p2003thk8cwoiwzpz6	cmpfexe0c01puhkzb3pkg2qkg	18	D	Genel Yetenek	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p2003uhk8cyg4cphgv	cmpfexe0c01puhkzb3pkg2qkg	19	A	Genel Yetenek	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p2003vhk8c5gcraejo	cmpfexe0c01puhkzb3pkg2qkg	20	C	Genel Yetenek	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p3003whk8cuba4lw21	cmpfexe0c01puhkzb3pkg2qkg	21	B	Genel Yetenek	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p3003xhk8cdfz77als	cmpfexe0c01puhkzb3pkg2qkg	22	E	Genel Yetenek	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p3003yhk8cke8685mz	cmpfexe0c01puhkzb3pkg2qkg	23	E	Genel Yetenek	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p3003zhk8cpgaqt0li	cmpfexe0c01puhkzb3pkg2qkg	24	B	Genel Yetenek	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p30040hk8c2nh7o66c	cmpfexe0c01puhkzb3pkg2qkg	25	B	Genel Yetenek	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p30041hk8cj16x624s	cmpfexe0c01puhkzb3pkg2qkg	26	D	Genel Yetenek	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p30042hk8chofidr04	cmpfexe0c01puhkzb3pkg2qkg	27	A	Genel Yetenek	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p30043hk8cg7nw3uu0	cmpfexe0c01puhkzb3pkg2qkg	28	B	Genel Yetenek	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p30044hk8cfn1cm87y	cmpfexe0c01puhkzb3pkg2qkg	29	B	Genel Yetenek	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p30045hk8c6q5h4khb	cmpfexe0c01puhkzb3pkg2qkg	30	C	Genel Yetenek	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p30046hk8chfp9bdj1	cmpfexe0c01puhkzb3pkg2qkg	31	E	Genel Yetenek	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p30047hk8chbxy8lxt	cmpfexe0c01puhkzb3pkg2qkg	32	A	Genel Yetenek	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p30048hk8cm5tdxhmb	cmpfexe0c01puhkzb3pkg2qkg	33	B	Genel Yetenek	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p30049hk8cf39ur0es	cmpfexe0c01puhkzb3pkg2qkg	34	C	Genel Yetenek	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p3004ahk8cyx5r2z0z	cmpfexe0c01puhkzb3pkg2qkg	35	D	Genel Yetenek	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p3004bhk8c6dfgfcft	cmpfexe0c01puhkzb3pkg2qkg	36	E	Genel Yetenek	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p3004chk8c4heyd0ot	cmpfexe0c01puhkzb3pkg2qkg	37	C	Genel Yetenek	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p3004dhk8cmwdkmmkt	cmpfexe0c01puhkzb3pkg2qkg	38	E	Genel Yetenek	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p3004ehk8cmuqpldfs	cmpfexe0c01puhkzb3pkg2qkg	39	D	Genel Yetenek	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p3004fhk8cefecgy8h	cmpfexe0c01puhkzb3pkg2qkg	40	C	Genel Yetenek	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p3004ghk8crv0khj4i	cmpfexe0c01puhkzb3pkg2qkg	41	A	Genel Yetenek	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p3004hhk8cdytqmsgi	cmpfexe0c01puhkzb3pkg2qkg	42	D	Genel Yetenek	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p3004ihk8cxjmnv83c	cmpfexe0c01puhkzb3pkg2qkg	43	C	Genel Yetenek	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p3004jhk8c5owqj548	cmpfexe0c01puhkzb3pkg2qkg	44	D	Genel Yetenek	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p3004khk8c3t4gqglw	cmpfexe0c01puhkzb3pkg2qkg	45	C	Genel Yetenek	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p3004lhk8ctq6fva7e	cmpfexe0c01puhkzb3pkg2qkg	46	D	Genel Yetenek	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p3004mhk8c3phuo7j7	cmpfexe0c01puhkzb3pkg2qkg	47	B	Genel Yetenek	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p3004nhk8co8tlrbgt	cmpfexe0c01puhkzb3pkg2qkg	48	C	Genel Yetenek	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p3004ohk8cwf90e73c	cmpfexe0c01puhkzb3pkg2qkg	49	E	Genel Yetenek	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p3004phk8c0txesxur	cmpfexe0c01puhkzb3pkg2qkg	50	D	Genel Yetenek	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p3004qhk8cqq79mxpm	cmpfexe0c01puhkzb3pkg2qkg	51	B	Genel Yetenek	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p4004rhk8c7u0a9v11	cmpfexe0c01puhkzb3pkg2qkg	52	A	Genel Yetenek	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p4004shk8cpx7rquar	cmpfexe0c01puhkzb3pkg2qkg	53	B	Genel Yetenek	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p4004thk8clvrztyep	cmpfexe0c01puhkzb3pkg2qkg	54	E	Genel Yetenek	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p4004uhk8c910tntvo	cmpfexe0c01puhkzb3pkg2qkg	55	C	Genel Yetenek	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p4004vhk8cp3lyeghp	cmpfexe0c01puhkzb3pkg2qkg	56	A	Genel Yetenek	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p4004whk8cqvksyyxl	cmpfexe0c01puhkzb3pkg2qkg	57	C	Genel Yetenek	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p4004xhk8cr8lyb7fs	cmpfexe0c01puhkzb3pkg2qkg	58	B	Genel Yetenek	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p4004yhk8c4q6elrly	cmpfexe0c01puhkzb3pkg2qkg	59	D	Genel Yetenek	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p4004zhk8cyh69gihq	cmpfexe0c01puhkzb3pkg2qkg	60	D	Genel Yetenek	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p40050hk8cgza2u8yc	cmpfexe0c01puhkzb3pkg2qkg	61	D	Genel Kültür	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p40051hk8c4qh6a6cx	cmpfexe0c01puhkzb3pkg2qkg	62	B	Genel Kültür	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p40052hk8csml2q7y2	cmpfexe0c01puhkzb3pkg2qkg	63	B	Genel Kültür	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p40053hk8cyd9poyj7	cmpfexe0c01puhkzb3pkg2qkg	64	C	Genel Kültür	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p40054hk8caj56gh16	cmpfexe0c01puhkzb3pkg2qkg	65	E	Genel Kültür	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p40055hk8ca3sbhhc4	cmpfexe0c01puhkzb3pkg2qkg	66	E	Genel Kültür	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p40056hk8cuf71wrsn	cmpfexe0c01puhkzb3pkg2qkg	67	A	Genel Kültür	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p40057hk8cr24qs7j5	cmpfexe0c01puhkzb3pkg2qkg	68	A	Genel Kültür	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p40058hk8cp5l631zt	cmpfexe0c01puhkzb3pkg2qkg	69	C	Genel Kültür	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p40059hk8caq98bbvw	cmpfexe0c01puhkzb3pkg2qkg	70	A	Genel Kültür	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p4005ahk8cmgosctax	cmpfexe0c01puhkzb3pkg2qkg	71	C	Genel Kültür	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p4005bhk8cm9p1uvw6	cmpfexe0c01puhkzb3pkg2qkg	72	A	Genel Kültür	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p4005chk8c9o1zwxjl	cmpfexe0c01puhkzb3pkg2qkg	73	E	Genel Kültür	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p4005dhk8cbg01ytec	cmpfexe0c01puhkzb3pkg2qkg	74	C	Genel Kültür	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p4005ehk8c5nbzsxra	cmpfexe0c01puhkzb3pkg2qkg	75	B	Genel Kültür	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p4005fhk8cfo3eevxp	cmpfexe0c01puhkzb3pkg2qkg	76	A	Genel Kültür	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p4005ghk8ckbuudvk3	cmpfexe0c01puhkzb3pkg2qkg	77	B	Genel Kültür	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p4005hhk8crnd9ige1	cmpfexe0c01puhkzb3pkg2qkg	78	A	Genel Kültür	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p4005ihk8c8hma0lyv	cmpfexe0c01puhkzb3pkg2qkg	79	C	Genel Kültür	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p4005jhk8cz6pz222e	cmpfexe0c01puhkzb3pkg2qkg	80	A	Genel Kültür	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p5005khk8ca3i8gl6a	cmpfexe0c01puhkzb3pkg2qkg	81	D	Genel Kültür	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p5005lhk8cu30zc6an	cmpfexe0c01puhkzb3pkg2qkg	82	C	Genel Kültür	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p5005mhk8cjczn9pma	cmpfexe0c01puhkzb3pkg2qkg	83	D	Genel Kültür	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p5005nhk8c9onlohrv	cmpfexe0c01puhkzb3pkg2qkg	84	B	Genel Kültür	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p5005ohk8c6wsy22sz	cmpfexe0c01puhkzb3pkg2qkg	85	E	Genel Kültür	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p5005phk8cy4xkt675	cmpfexe0c01puhkzb3pkg2qkg	86	C	Genel Kültür	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p5005qhk8c67qkd7kr	cmpfexe0c01puhkzb3pkg2qkg	87	D	Genel Kültür	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p5005rhk8crky5ao02	cmpfexe0c01puhkzb3pkg2qkg	88	B	Genel Kültür	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p5005shk8clloldos7	cmpfexe0c01puhkzb3pkg2qkg	89	C	Genel Kültür	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p5005thk8c71j8akf6	cmpfexe0c01puhkzb3pkg2qkg	90	A	Genel Kültür	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p5005uhk8cg6lv3dx0	cmpfexe0c01puhkzb3pkg2qkg	91	A	Genel Kültür	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p5005vhk8cxg0je8s5	cmpfexe0c01puhkzb3pkg2qkg	92	D	Genel Kültür	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p5005whk8ch8jyacee	cmpfexe0c01puhkzb3pkg2qkg	93	D	Genel Kültür	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p5005xhk8cm0n2pmmm	cmpfexe0c01puhkzb3pkg2qkg	94	D	Genel Kültür	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p5005yhk8cu2h2bnl3	cmpfexe0c01puhkzb3pkg2qkg	95	E	Genel Kültür	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p5005zhk8cyikyeaqc	cmpfexe0c01puhkzb3pkg2qkg	96	A	Genel Kültür	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p50060hk8c3g7c8man	cmpfexe0c01puhkzb3pkg2qkg	97	A	Genel Kültür	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p50061hk8ck9ns2cff	cmpfexe0c01puhkzb3pkg2qkg	98	B	Genel Kültür	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p50062hk8cu8f5ggo4	cmpfexe0c01puhkzb3pkg2qkg	99	D	Genel Kültür	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p50063hk8c99yk64h0	cmpfexe0c01puhkzb3pkg2qkg	100	C	Genel Kültür	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p50064hk8cjomvvd89	cmpfexe0c01puhkzb3pkg2qkg	101	D	Genel Kültür	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p50065hk8c5sc8n2nw	cmpfexe0c01puhkzb3pkg2qkg	102	A	Genel Kültür	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p50066hk8cajye7ecd	cmpfexe0c01puhkzb3pkg2qkg	103	C	Genel Kültür	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p50067hk8cs4plnz3z	cmpfexe0c01puhkzb3pkg2qkg	104	A	Genel Kültür	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p50068hk8cs8rae8lu	cmpfexe0c01puhkzb3pkg2qkg	105	A	Genel Kültür	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p50069hk8cayv5srw0	cmpfexe0c01puhkzb3pkg2qkg	106	C	Genel Kültür	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p5006ahk8cyo5wb5qz	cmpfexe0c01puhkzb3pkg2qkg	107	B	Genel Kültür	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p5006bhk8cbnlblxda	cmpfexe0c01puhkzb3pkg2qkg	108	D	Genel Kültür	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p5006chk8cf94qdu4b	cmpfexe0c01puhkzb3pkg2qkg	109	C	Genel Kültür	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p5006dhk8cea4m8lnx	cmpfexe0c01puhkzb3pkg2qkg	110	E	Genel Kültür	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p6006ehk8chalbx660	cmpfexe0c01puhkzb3pkg2qkg	111	C	Genel Kültür	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p6006fhk8ci5c6ml3z	cmpfexe0c01puhkzb3pkg2qkg	112	C	Genel Kültür	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p6006ghk8ctpjvdtxu	cmpfexe0c01puhkzb3pkg2qkg	113	A	Genel Kültür	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p6006hhk8c98powhp9	cmpfexe0c01puhkzb3pkg2qkg	114	E	Genel Kültür	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p6006ihk8cfhhq9r5l	cmpfexe0c01puhkzb3pkg2qkg	115	C	Genel Kültür	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p6006jhk8czynqjgw4	cmpfexe0c01puhkzb3pkg2qkg	116	B	Genel Kültür	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p6006khk8clzrygqtk	cmpfexe0c01puhkzb3pkg2qkg	117	A	Genel Kültür	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p6006lhk8c6m0uazij	cmpfexe0c01puhkzb3pkg2qkg	118	C	Genel Kültür	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p6006mhk8cly4mg1b2	cmpfexe0c01puhkzb3pkg2qkg	119	A	Genel Kültür	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzjy4p6006nhk8cxu5dqcbk	cmpfexe0c01puhkzb3pkg2qkg	120	B	Genel Kültür	2026-06-04 13:49:49.764	2026-06-04 13:49:49.764	0.1	\N
cmpzkdjo000dchk8c6gj6ofad	cmpwswxce0002hkwpttlr7zwx	1	C	Genel Yetenek	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo000ddhk8cqwxj1kfs	cmpwswxce0002hkwpttlr7zwx	2	E	Genel Yetenek	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo000dehk8c10yqan0u	cmpwswxce0002hkwpttlr7zwx	3	A	Genel Yetenek	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo000dfhk8c38d8w8n8	cmpwswxce0002hkwpttlr7zwx	4	B	Genel Yetenek	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo000dghk8c48us6yuy	cmpwswxce0002hkwpttlr7zwx	5	C	Genel Yetenek	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo100dhhk8cpn67s4xz	cmpwswxce0002hkwpttlr7zwx	6	D	Genel Yetenek	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo100dihk8c5hje11lr	cmpwswxce0002hkwpttlr7zwx	7	E	Genel Yetenek	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo100djhk8cxx3tak97	cmpwswxce0002hkwpttlr7zwx	8	B	Genel Yetenek	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo100dkhk8c3idzflzs	cmpwswxce0002hkwpttlr7zwx	9	D	Genel Yetenek	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo100dlhk8czxi3bvmi	cmpwswxce0002hkwpttlr7zwx	10	C	Genel Yetenek	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo100dmhk8co7jzfavx	cmpwswxce0002hkwpttlr7zwx	11	D	Genel Yetenek	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo100dnhk8c91zkkxy8	cmpwswxce0002hkwpttlr7zwx	12	E	Genel Yetenek	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo100dohk8cdmj2b0ww	cmpwswxce0002hkwpttlr7zwx	13	D	Genel Yetenek	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo100dphk8ce6aa1reb	cmpwswxce0002hkwpttlr7zwx	14	A	Genel Yetenek	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo100dqhk8cf07trmva	cmpwswxce0002hkwpttlr7zwx	15	B	Genel Yetenek	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo100drhk8caulmok0w	cmpwswxce0002hkwpttlr7zwx	16	D	Genel Yetenek	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo100dshk8cy6bwdw07	cmpwswxce0002hkwpttlr7zwx	17	A	Genel Yetenek	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo100dthk8cct4k9kko	cmpwswxce0002hkwpttlr7zwx	18	A	Genel Yetenek	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo100duhk8cjf58c48b	cmpwswxce0002hkwpttlr7zwx	19	E	Genel Yetenek	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo100dvhk8clyw6gaix	cmpwswxce0002hkwpttlr7zwx	20	C	Genel Yetenek	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo100dwhk8c3p8jrg8v	cmpwswxce0002hkwpttlr7zwx	21	E	Genel Yetenek	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo100dxhk8c3c4gkkng	cmpwswxce0002hkwpttlr7zwx	22	D	Genel Yetenek	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo100dyhk8cmzsk2zzb	cmpwswxce0002hkwpttlr7zwx	23	D	Genel Yetenek	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo100dzhk8ckfbuwm43	cmpwswxce0002hkwpttlr7zwx	24	E	Genel Yetenek	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo100e0hk8c85dy524y	cmpwswxce0002hkwpttlr7zwx	25	C	Genel Yetenek	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo100e1hk8c75q6ynom	cmpwswxce0002hkwpttlr7zwx	26	A	Genel Yetenek	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo100e2hk8c0c8q0myh	cmpwswxce0002hkwpttlr7zwx	27	A	Genel Yetenek	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo100e3hk8cnrmm5wz0	cmpwswxce0002hkwpttlr7zwx	28	A	Genel Yetenek	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo100e4hk8cbejws7z4	cmpwswxce0002hkwpttlr7zwx	29	D	Genel Yetenek	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo100e5hk8cirnc44bw	cmpwswxce0002hkwpttlr7zwx	30	C	Genel Yetenek	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo100e6hk8cqkbhtw92	cmpwswxce0002hkwpttlr7zwx	31	D	Genel Yetenek	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo100e7hk8cu1r4oaij	cmpwswxce0002hkwpttlr7zwx	32	C	Genel Yetenek	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo100e8hk8cwwqyddwd	cmpwswxce0002hkwpttlr7zwx	33	B	Genel Yetenek	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo100e9hk8cxawhgzxh	cmpwswxce0002hkwpttlr7zwx	34	A	Genel Yetenek	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo100eahk8cxtxfio2n	cmpwswxce0002hkwpttlr7zwx	35	C	Genel Yetenek	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo200ebhk8cgta1s13p	cmpwswxce0002hkwpttlr7zwx	36	B	Genel Yetenek	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo200echk8cx4ibic27	cmpwswxce0002hkwpttlr7zwx	37	C	Genel Yetenek	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo200edhk8c0fcysym7	cmpwswxce0002hkwpttlr7zwx	38	C	Genel Yetenek	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo200eehk8c5j1a5f7r	cmpwswxce0002hkwpttlr7zwx	39	A	Genel Yetenek	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo200efhk8ca312pdvu	cmpwswxce0002hkwpttlr7zwx	40	D	Genel Yetenek	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo200eghk8cqhco7z1q	cmpwswxce0002hkwpttlr7zwx	41	B	Genel Yetenek	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo200ehhk8c27ou2yxy	cmpwswxce0002hkwpttlr7zwx	42	A	Genel Yetenek	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo200eihk8chckau2cp	cmpwswxce0002hkwpttlr7zwx	43	A	Genel Yetenek	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo200ejhk8c7txmaptt	cmpwswxce0002hkwpttlr7zwx	44	C	Genel Yetenek	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo200ekhk8c29if3754	cmpwswxce0002hkwpttlr7zwx	45	B	Genel Yetenek	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo200elhk8cz1iisuki	cmpwswxce0002hkwpttlr7zwx	46	D	Genel Yetenek	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo200emhk8csafvzaxm	cmpwswxce0002hkwpttlr7zwx	47	C	Genel Yetenek	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo200enhk8c2p1pvygc	cmpwswxce0002hkwpttlr7zwx	48	E	Genel Yetenek	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo200eohk8cgz5s9n49	cmpwswxce0002hkwpttlr7zwx	49	D	Genel Yetenek	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo200ephk8cix7x29dg	cmpwswxce0002hkwpttlr7zwx	50	B	Genel Yetenek	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo200eqhk8c2ea4j4lu	cmpwswxce0002hkwpttlr7zwx	51	D	Genel Yetenek	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo200erhk8ce01ln7z6	cmpwswxce0002hkwpttlr7zwx	52	C	Genel Yetenek	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo200eshk8cqw6v15kt	cmpwswxce0002hkwpttlr7zwx	53	C	Genel Yetenek	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo200ethk8cpveheqni	cmpwswxce0002hkwpttlr7zwx	54	C	Genel Yetenek	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo200euhk8c13r7moim	cmpwswxce0002hkwpttlr7zwx	55	A	Genel Yetenek	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo200evhk8c62ypq4wl	cmpwswxce0002hkwpttlr7zwx	56	D	Genel Yetenek	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo200ewhk8cdq5q9hyf	cmpwswxce0002hkwpttlr7zwx	57	B	Genel Yetenek	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo200exhk8cxcy4o8n4	cmpwswxce0002hkwpttlr7zwx	58	E	Genel Yetenek	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo200eyhk8ck4d1n4pb	cmpwswxce0002hkwpttlr7zwx	59	C	Genel Yetenek	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo200ezhk8ckx4te95e	cmpwswxce0002hkwpttlr7zwx	60	A	Genel Yetenek	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo200f0hk8c0vmqws88	cmpwswxce0002hkwpttlr7zwx	61	E	Genel Kültür	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo200f1hk8cb1efremh	cmpwswxce0002hkwpttlr7zwx	62	C	Genel Kültür	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo200f2hk8c0t2z6180	cmpwswxce0002hkwpttlr7zwx	63	B	Genel Kültür	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo200f3hk8cjpiiznbv	cmpwswxce0002hkwpttlr7zwx	64	E	Genel Kültür	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo200f4hk8cvfhrvzqy	cmpwswxce0002hkwpttlr7zwx	65	B	Genel Kültür	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo200f5hk8c05kzg6tb	cmpwswxce0002hkwpttlr7zwx	66	D	Genel Kültür	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo200f6hk8chm8wjnj5	cmpwswxce0002hkwpttlr7zwx	67	D	Genel Kültür	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo200f7hk8cvdpr9v03	cmpwswxce0002hkwpttlr7zwx	68	D	Genel Kültür	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo200f8hk8ctw7oke4m	cmpwswxce0002hkwpttlr7zwx	69	E	Genel Kültür	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo300f9hk8cfzmuw2co	cmpwswxce0002hkwpttlr7zwx	70	C	Genel Kültür	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo300fahk8cahy2yp08	cmpwswxce0002hkwpttlr7zwx	71	B	Genel Kültür	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo300fbhk8ciubk618q	cmpwswxce0002hkwpttlr7zwx	72	B	Genel Kültür	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo300fchk8clq51aqxf	cmpwswxce0002hkwpttlr7zwx	73	D	Genel Kültür	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo300fdhk8ch5u98eeg	cmpwswxce0002hkwpttlr7zwx	74	A	Genel Kültür	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo300fehk8c0i3lo813	cmpwswxce0002hkwpttlr7zwx	75	E	Genel Kültür	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo300ffhk8cnfc09kw7	cmpwswxce0002hkwpttlr7zwx	76	C	Genel Kültür	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo300fghk8cb3r8sbag	cmpwswxce0002hkwpttlr7zwx	77	B	Genel Kültür	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo300fhhk8cpe4ng48c	cmpwswxce0002hkwpttlr7zwx	78	C	Genel Kültür	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo300fihk8caxh5nnk4	cmpwswxce0002hkwpttlr7zwx	79	E	Genel Kültür	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo300fjhk8c1d4wlx38	cmpwswxce0002hkwpttlr7zwx	80	C	Genel Kültür	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo300fkhk8c9k551vun	cmpwswxce0002hkwpttlr7zwx	81	A	Genel Kültür	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo300flhk8c46id62c3	cmpwswxce0002hkwpttlr7zwx	82	D	Genel Kültür	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmq0pfka400dnhk8d7axhdby1	cmpxw7hz500pzhke6tmzzhqma	12	E	Genel Test	2026-06-05 09:11:07.371	2026-06-05 09:11:07.371	0.1	\N
cmq0pfka400dohk8doq3qogh1	cmpxw7hz500pzhke6tmzzhqma	13	C	Genel Test	2026-06-05 09:11:07.371	2026-06-05 09:11:07.371	0.1	\N
cmq0pfka400dphk8ds69isg85	cmpxw7hz500pzhke6tmzzhqma	14	A	Genel Test	2026-06-05 09:11:07.371	2026-06-05 09:11:07.371	0.1	\N
cmq0pfka400dqhk8d7uf01j7i	cmpxw7hz500pzhke6tmzzhqma	15	E	Genel Test	2026-06-05 09:11:07.371	2026-06-05 09:11:07.371	0.1	\N
cmq0pfka400drhk8d9v4pm9w9	cmpxw7hz500pzhke6tmzzhqma	16	D	Genel Test	2026-06-05 09:11:07.371	2026-06-05 09:11:07.371	0.1	\N
cmq0pfka400dshk8dppxo50od	cmpxw7hz500pzhke6tmzzhqma	17	D	Genel Test	2026-06-05 09:11:07.371	2026-06-05 09:11:07.371	0.1	\N
cmq0pfka400dthk8djx5l1pgw	cmpxw7hz500pzhke6tmzzhqma	18	A	Genel Test	2026-06-05 09:11:07.371	2026-06-05 09:11:07.371	0.1	\N
cmq0pfka400duhk8dv5ibqg4b	cmpxw7hz500pzhke6tmzzhqma	19	C	Genel Test	2026-06-05 09:11:07.371	2026-06-05 09:11:07.371	0.1	\N
cmq0pfka400dvhk8d27eldsyr	cmpxw7hz500pzhke6tmzzhqma	20	E	Genel Test	2026-06-05 09:11:07.371	2026-06-05 09:11:07.371	0.1	\N
cmq0pfka400dwhk8db932lbx5	cmpxw7hz500pzhke6tmzzhqma	21	B	Genel Test	2026-06-05 09:11:07.371	2026-06-05 09:11:07.371	0.1	\N
cmq0pfka400dxhk8dxjmtfxg9	cmpxw7hz500pzhke6tmzzhqma	22	A	Genel Test	2026-06-05 09:11:07.371	2026-06-05 09:11:07.371	0.1	\N
cmq0pfka400dyhk8dv6nvr9ad	cmpxw7hz500pzhke6tmzzhqma	23	C	Genel Test	2026-06-05 09:11:07.371	2026-06-05 09:11:07.371	0.1	\N
cmq0pfka400dzhk8dpklm6paf	cmpxw7hz500pzhke6tmzzhqma	24	E	Genel Test	2026-06-05 09:11:07.371	2026-06-05 09:11:07.371	0.1	\N
cmq0pfka400e0hk8dks98aq87	cmpxw7hz500pzhke6tmzzhqma	25	C	Genel Test	2026-06-05 09:11:07.371	2026-06-05 09:11:07.371	0.1	\N
cmq0pfka400e1hk8d7eqd407d	cmpxw7hz500pzhke6tmzzhqma	26	A	Genel Test	2026-06-05 09:11:07.371	2026-06-05 09:11:07.371	0.1	\N
cmq0pfka400e2hk8d23mb5ugb	cmpxw7hz500pzhke6tmzzhqma	27	E	Genel Test	2026-06-05 09:11:07.371	2026-06-05 09:11:07.371	0.1	\N
cmq0pfka400e3hk8dk6vjcs8z	cmpxw7hz500pzhke6tmzzhqma	28	C	Genel Test	2026-06-05 09:11:07.371	2026-06-05 09:11:07.371	0.1	\N
cmq0pfka400e4hk8d776xco2b	cmpxw7hz500pzhke6tmzzhqma	29	D	Genel Test	2026-06-05 09:11:07.371	2026-06-05 09:11:07.371	0.1	\N
cmq0pfka400e5hk8dq49oscs3	cmpxw7hz500pzhke6tmzzhqma	30	D	Genel Test	2026-06-05 09:11:07.371	2026-06-05 09:11:07.371	0.1	\N
cmq0pfka500e6hk8dka3ih8ja	cmpxw7hz500pzhke6tmzzhqma	31	D	Genel Test	2026-06-05 09:11:07.371	2026-06-05 09:11:07.371	0.1	\N
cmq0pfka500e7hk8dy8bo5fpr	cmpxw7hz500pzhke6tmzzhqma	32	E	Genel Test	2026-06-05 09:11:07.371	2026-06-05 09:11:07.371	0.1	\N
cmq0pfka500e8hk8dpjcl44sm	cmpxw7hz500pzhke6tmzzhqma	33	D	Genel Test	2026-06-05 09:11:07.371	2026-06-05 09:11:07.371	0.1	\N
cmq0pfka500e9hk8da3bxaiz3	cmpxw7hz500pzhke6tmzzhqma	34	B	Genel Test	2026-06-05 09:11:07.371	2026-06-05 09:11:07.371	0.1	\N
cmq0pfka500eahk8d5ewahf75	cmpxw7hz500pzhke6tmzzhqma	35	C	Genel Test	2026-06-05 09:11:07.371	2026-06-05 09:11:07.371	0.1	\N
cmq0pfka500ebhk8dmpa29l3q	cmpxw7hz500pzhke6tmzzhqma	36	B	Genel Test	2026-06-05 09:11:07.371	2026-06-05 09:11:07.371	0.1	\N
cmq0pfka500echk8dw74n0y01	cmpxw7hz500pzhke6tmzzhqma	37	E	Genel Test	2026-06-05 09:11:07.371	2026-06-05 09:11:07.371	0.1	\N
cmq0pfka500edhk8dyeyjm9j5	cmpxw7hz500pzhke6tmzzhqma	38	C	Genel Test	2026-06-05 09:11:07.371	2026-06-05 09:11:07.371	0.1	\N
cmq0pfka500eehk8dxu7kanzq	cmpxw7hz500pzhke6tmzzhqma	39	B	Genel Test	2026-06-05 09:11:07.371	2026-06-05 09:11:07.371	0.1	\N
cmq0pfka500efhk8ds1ou46bw	cmpxw7hz500pzhke6tmzzhqma	40	B	Genel Test	2026-06-05 09:11:07.371	2026-06-05 09:11:07.371	0.1	\N
cmq0pfy9o00eghk8dzszpo4mk	cmpxw5zub00oshke69lnxt9hl	1	E	Genel Test	2026-06-05 09:11:25.5	2026-06-05 09:11:25.5	0.2	\N
cmq0pfy9o00ehhk8dxpzo5vf9	cmpxw5zub00oshke69lnxt9hl	2	B	Genel Test	2026-06-05 09:11:25.5	2026-06-05 09:11:25.5	0.2	\N
cmq0pfy9o00eihk8d3tgcdnpz	cmpxw5zub00oshke69lnxt9hl	3	E	Genel Test	2026-06-05 09:11:25.5	2026-06-05 09:11:25.5	0.2	\N
cmq0pfy9o00ejhk8dehrkfiga	cmpxw5zub00oshke69lnxt9hl	4	B	Genel Test	2026-06-05 09:11:25.5	2026-06-05 09:11:25.5	0.2	\N
cmq0pfy9o00ekhk8dlw1cgkut	cmpxw5zub00oshke69lnxt9hl	5	C	Genel Test	2026-06-05 09:11:25.5	2026-06-05 09:11:25.5	0.2	\N
cmq0pfy9o00elhk8dd3kj06ou	cmpxw5zub00oshke69lnxt9hl	6	D	Genel Test	2026-06-05 09:11:25.5	2026-06-05 09:11:25.5	0.2	\N
cmq0pfy9o00emhk8d5ooa3eti	cmpxw5zub00oshke69lnxt9hl	7	E	Genel Test	2026-06-05 09:11:25.5	2026-06-05 09:11:25.5	0.2	\N
cmq0pfy9o00enhk8d8d9qoict	cmpxw5zub00oshke69lnxt9hl	8	D	Genel Test	2026-06-05 09:11:25.5	2026-06-05 09:11:25.5	0.2	\N
cmq0pfy9o00eohk8d81x59kbs	cmpxw5zub00oshke69lnxt9hl	9	B	Genel Test	2026-06-05 09:11:25.5	2026-06-05 09:11:25.5	0.2	\N
cmq0qaxm601dehk8dr5d036cn	cmpfka7qt01xqhkzbwuyum22o	59	C	Genel Yetenek	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm601dfhk8d64fgisek	cmpfka7qt01xqhkzbwuyum22o	60	B	Genel Yetenek	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm601dghk8dcqh8orbv	cmpfka7qt01xqhkzbwuyum22o	61	C	Genel Kültür	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm601dhhk8d84asu4zo	cmpfka7qt01xqhkzbwuyum22o	62	E	Genel Kültür	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm601dihk8d6kiyb88d	cmpfka7qt01xqhkzbwuyum22o	63	B	Genel Kültür	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm601djhk8dtnvo983t	cmpfka7qt01xqhkzbwuyum22o	64	C	Genel Kültür	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm601dkhk8djrtq7vn9	cmpfka7qt01xqhkzbwuyum22o	65	A	Genel Kültür	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm601dlhk8djis56qr2	cmpfka7qt01xqhkzbwuyum22o	66	A	Genel Kültür	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm601dmhk8dnheh7xek	cmpfka7qt01xqhkzbwuyum22o	67	D	Genel Kültür	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm601dnhk8dmu6ddd6r	cmpfka7qt01xqhkzbwuyum22o	68	A	Genel Kültür	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm601dohk8d98pq5pnr	cmpfka7qt01xqhkzbwuyum22o	69	D	Genel Kültür	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm601dphk8dsmg3uejc	cmpfka7qt01xqhkzbwuyum22o	70	D	Genel Kültür	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm601dqhk8dal3d3lsj	cmpfka7qt01xqhkzbwuyum22o	71	E	Genel Kültür	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm601drhk8dsjrb2vni	cmpfka7qt01xqhkzbwuyum22o	72	E	Genel Kültür	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm601dshk8dipnoiy5b	cmpfka7qt01xqhkzbwuyum22o	73	D	Genel Kültür	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm601dthk8dufz033gp	cmpfka7qt01xqhkzbwuyum22o	74	A	Genel Kültür	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm601duhk8dw0naag58	cmpfka7qt01xqhkzbwuyum22o	75	E	Genel Kültür	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm601dvhk8dz20qsy1b	cmpfka7qt01xqhkzbwuyum22o	76	C	Genel Kültür	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm601dwhk8d6g2khyfb	cmpfka7qt01xqhkzbwuyum22o	77	B	Genel Kültür	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm601dxhk8db9t9jmm1	cmpfka7qt01xqhkzbwuyum22o	78	D	Genel Kültür	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm601dyhk8dyfj8dpii	cmpfka7qt01xqhkzbwuyum22o	79	D	Genel Kültür	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm601dzhk8d9m6zdjpa	cmpfka7qt01xqhkzbwuyum22o	80	D	Genel Kültür	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm601e0hk8de5gmt0q0	cmpfka7qt01xqhkzbwuyum22o	81	E	Genel Kültür	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm601e1hk8dfc3tsph6	cmpfka7qt01xqhkzbwuyum22o	82	D	Genel Kültür	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm601e2hk8dfyf4nchm	cmpfka7qt01xqhkzbwuyum22o	83	D	Genel Kültür	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm601e3hk8de0wbchzv	cmpfka7qt01xqhkzbwuyum22o	84	C	Genel Kültür	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm701e4hk8dut9vvcaq	cmpfka7qt01xqhkzbwuyum22o	85	E	Genel Kültür	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm701e5hk8d9b1ljmcq	cmpfka7qt01xqhkzbwuyum22o	86	A	Genel Kültür	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm701e6hk8dykullgtb	cmpfka7qt01xqhkzbwuyum22o	87	A	Genel Kültür	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm701e7hk8dr8efs0hh	cmpfka7qt01xqhkzbwuyum22o	88	C	Genel Kültür	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm701e8hk8dkhxat9oi	cmpfka7qt01xqhkzbwuyum22o	89	A	Genel Kültür	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm701e9hk8djlmec42d	cmpfka7qt01xqhkzbwuyum22o	90	E	Genel Kültür	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm701eahk8doauhhe13	cmpfka7qt01xqhkzbwuyum22o	91	A	Genel Kültür	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm701ebhk8duvacpn1w	cmpfka7qt01xqhkzbwuyum22o	92	A	Genel Kültür	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm701echk8dmalnbms4	cmpfka7qt01xqhkzbwuyum22o	93	A	Genel Kültür	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm701edhk8dovjmie4u	cmpfka7qt01xqhkzbwuyum22o	94	B	Genel Kültür	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm701eehk8dry5nhu0x	cmpfka7qt01xqhkzbwuyum22o	95	E	Genel Kültür	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm701efhk8dynj5v6iq	cmpfka7qt01xqhkzbwuyum22o	96	A	Genel Kültür	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm701eghk8dffjnvnho	cmpfka7qt01xqhkzbwuyum22o	97	A	Genel Kültür	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm701ehhk8dohqz7ovj	cmpfka7qt01xqhkzbwuyum22o	98	D	Genel Kültür	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm701eihk8d1rzf3t0o	cmpfka7qt01xqhkzbwuyum22o	99	D	Genel Kültür	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm701ejhk8dzprwkxiq	cmpfka7qt01xqhkzbwuyum22o	100	E	Genel Kültür	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm701ekhk8dntt8h2hg	cmpfka7qt01xqhkzbwuyum22o	101	B	Genel Kültür	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm701elhk8dh8vcyamp	cmpfka7qt01xqhkzbwuyum22o	102	E	Genel Kültür	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm701emhk8dkj17ghht	cmpfka7qt01xqhkzbwuyum22o	103	B	Genel Kültür	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm701enhk8d2mvtbils	cmpfka7qt01xqhkzbwuyum22o	104	E	Genel Kültür	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm701eohk8dtalvnnik	cmpfka7qt01xqhkzbwuyum22o	105	B	Genel Kültür	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm701ephk8dycmsewrm	cmpfka7qt01xqhkzbwuyum22o	106	E	Genel Kültür	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm701eqhk8dfos68rc7	cmpfka7qt01xqhkzbwuyum22o	107	C	Genel Kültür	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm701erhk8dbs5dewki	cmpfka7qt01xqhkzbwuyum22o	108	B	Genel Kültür	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm701eshk8dpr2t9irg	cmpfka7qt01xqhkzbwuyum22o	109	B	Genel Kültür	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm701ethk8dcw04vni2	cmpfka7qt01xqhkzbwuyum22o	110	D	Genel Kültür	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm701euhk8d2y2zu557	cmpfka7qt01xqhkzbwuyum22o	111	B	Genel Kültür	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm701evhk8dwwc88073	cmpfka7qt01xqhkzbwuyum22o	112	D	Genel Kültür	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm701ewhk8d1sgz8x8l	cmpfka7qt01xqhkzbwuyum22o	113	D	Genel Kültür	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm701exhk8db6ftzd0h	cmpfka7qt01xqhkzbwuyum22o	114	B	Genel Kültür	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm701eyhk8dqrqq5sok	cmpfka7qt01xqhkzbwuyum22o	115	C	Genel Kültür	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm801ezhk8d5dmt1ol3	cmpfka7qt01xqhkzbwuyum22o	116	A	Genel Kültür	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm801f0hk8dd3q4rw4x	cmpfka7qt01xqhkzbwuyum22o	117	E	Genel Kültür	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm801f1hk8dxyx4syqd	cmpfka7qt01xqhkzbwuyum22o	118	E	Genel Kültür	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm801f2hk8dywgk7b65	cmpfka7qt01xqhkzbwuyum22o	119	D	Genel Kültür	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qaxm801f3hk8dl65ynueq	cmpfka7qt01xqhkzbwuyum22o	120	C	Genel Kültür	2026-06-05 09:35:30.987	2026-06-05 09:35:30.987	0.1	\N
cmq0qeplk01f4hk8ddnngocpo	cmpcfmqag00bohkdzqj6m6c8w	1	B	Genel Test	2026-06-05 09:38:27.224	2026-06-05 09:38:27.224	0.2	\N
cmq0qeplk01f5hk8d6137h93u	cmpcfmqag00bohkdzqj6m6c8w	2	D	Genel Test	2026-06-05 09:38:27.224	2026-06-05 09:38:27.224	0.2	\N
cmq0qeplk01f6hk8dbdotufr4	cmpcfmqag00bohkdzqj6m6c8w	3	B	Genel Test	2026-06-05 09:38:27.224	2026-06-05 09:38:27.224	0.2	\N
cmq0qeplk01f7hk8dazt7aiqm	cmpcfmqag00bohkdzqj6m6c8w	4	C	Genel Test	2026-06-05 09:38:27.224	2026-06-05 09:38:27.224	0.2	\N
cmq0qeplk01f8hk8dk2clke99	cmpcfmqag00bohkdzqj6m6c8w	5	C	Genel Test	2026-06-05 09:38:27.224	2026-06-05 09:38:27.224	0.2	\N
cmq0qeplk01f9hk8dtcg10zff	cmpcfmqag00bohkdzqj6m6c8w	6	A	Genel Test	2026-06-05 09:38:27.224	2026-06-05 09:38:27.224	0.2	\N
cmq0qeplk01fahk8dnbdtu9tt	cmpcfmqag00bohkdzqj6m6c8w	7	C	Genel Test	2026-06-05 09:38:27.224	2026-06-05 09:38:27.224	0.2	\N
cmq0qeplk01fbhk8d290x057s	cmpcfmqag00bohkdzqj6m6c8w	8	E	Genel Test	2026-06-05 09:38:27.224	2026-06-05 09:38:27.224	0.2	\N
cmq0qeplk01fchk8d2u1jl1ec	cmpcfmqag00bohkdzqj6m6c8w	9	D	Genel Test	2026-06-05 09:38:27.224	2026-06-05 09:38:27.224	0.2	\N
cmq0qeplk01fdhk8daec5n1rz	cmpcfmqag00bohkdzqj6m6c8w	10	B	Genel Test	2026-06-05 09:38:27.224	2026-06-05 09:38:27.224	0.2	\N
cmq0qeplk01fehk8d7ehfi2yg	cmpcfmqag00bohkdzqj6m6c8w	11	A	Genel Test	2026-06-05 09:38:27.224	2026-06-05 09:38:27.224	0.2	\N
cmq0qeplk01ffhk8dkgt7vvyx	cmpcfmqag00bohkdzqj6m6c8w	12	A	Genel Test	2026-06-05 09:38:27.224	2026-06-05 09:38:27.224	0.2	\N
cmq0qeplk01fghk8dcqp0um52	cmpcfmqag00bohkdzqj6m6c8w	13	E	Genel Test	2026-06-05 09:38:27.224	2026-06-05 09:38:27.224	0.2	\N
cmq0qeplk01fhhk8d93bxsbb0	cmpcfmqag00bohkdzqj6m6c8w	14	C	Genel Test	2026-06-05 09:38:27.224	2026-06-05 09:38:27.224	0.2	\N
cmq0qeplk01fihk8d4zygq5ws	cmpcfmqag00bohkdzqj6m6c8w	15	C	Genel Test	2026-06-05 09:38:27.224	2026-06-05 09:38:27.224	0.2	\N
cmq0qeplk01fjhk8d0qm31b06	cmpcfmqag00bohkdzqj6m6c8w	16	E	Genel Test	2026-06-05 09:38:27.224	2026-06-05 09:38:27.224	0.2	\N
cmq0qeplk01fkhk8dlhk7jlq3	cmpcfmqag00bohkdzqj6m6c8w	17	D	Genel Test	2026-06-05 09:38:27.224	2026-06-05 09:38:27.224	0.2	\N
cmq0qeplk01flhk8dco61p2u8	cmpcfmqag00bohkdzqj6m6c8w	18	E	Genel Test	2026-06-05 09:38:27.224	2026-06-05 09:38:27.224	0.2	\N
cmq0qeplk01fmhk8d8i298z9m	cmpcfmqag00bohkdzqj6m6c8w	19	C	Genel Test	2026-06-05 09:38:27.224	2026-06-05 09:38:27.224	0.2	\N
cmq0qeplk01fnhk8ds7ef7yzz	cmpcfmqag00bohkdzqj6m6c8w	20	D	Genel Test	2026-06-05 09:38:27.224	2026-06-05 09:38:27.224	0.2	\N
cmq0qepll01fohk8dfz1rwibv	cmpcfmqag00bohkdzqj6m6c8w	21	B	Genel Test	2026-06-05 09:38:27.224	2026-06-05 09:38:27.224	0.2	\N
cmq0qepll01fphk8dtwkjfym4	cmpcfmqag00bohkdzqj6m6c8w	22	B	Genel Test	2026-06-05 09:38:27.224	2026-06-05 09:38:27.224	0.2	\N
cmq0qepll01fqhk8dx4ddrgts	cmpcfmqag00bohkdzqj6m6c8w	23	D	Genel Test	2026-06-05 09:38:27.224	2026-06-05 09:38:27.224	0.2	\N
cmq0qepll01frhk8d9w08od4i	cmpcfmqag00bohkdzqj6m6c8w	24	C	Genel Test	2026-06-05 09:38:27.224	2026-06-05 09:38:27.224	0.2	\N
cmq0qepll01fshk8dozg53ykq	cmpcfmqag00bohkdzqj6m6c8w	25	D	Genel Test	2026-06-05 09:38:27.224	2026-06-05 09:38:27.224	0.2	\N
cmq0qepll01fthk8dw8jjnmm9	cmpcfmqag00bohkdzqj6m6c8w	26	A	Genel Test	2026-06-05 09:38:27.224	2026-06-05 09:38:27.224	0.2	\N
cmq0qepll01fuhk8dlywk6n69	cmpcfmqag00bohkdzqj6m6c8w	27	E	Genel Test	2026-06-05 09:38:27.224	2026-06-05 09:38:27.224	0.2	\N
cmq0qepll01fvhk8dcl045d33	cmpcfmqag00bohkdzqj6m6c8w	28	B	Genel Test	2026-06-05 09:38:27.224	2026-06-05 09:38:27.224	0.2	\N
cmq0qepll01fwhk8d1pa1csv1	cmpcfmqag00bohkdzqj6m6c8w	29	D	Genel Test	2026-06-05 09:38:27.224	2026-06-05 09:38:27.224	0.2	\N
cmq0qepll01fxhk8drbealq2d	cmpcfmqag00bohkdzqj6m6c8w	30	E	Genel Test	2026-06-05 09:38:27.224	2026-06-05 09:38:27.224	0.2	\N
cmq0qepll01fyhk8dfo3fig2x	cmpcfmqag00bohkdzqj6m6c8w	31	B	Genel Test	2026-06-05 09:38:27.224	2026-06-05 09:38:27.224	0.2	\N
cmq0qepll01fzhk8datpf5dqh	cmpcfmqag00bohkdzqj6m6c8w	32	C	Genel Test	2026-06-05 09:38:27.224	2026-06-05 09:38:27.224	0.2	\N
cmq0qepll01g0hk8d05p5yime	cmpcfmqag00bohkdzqj6m6c8w	33	E	Genel Test	2026-06-05 09:38:27.224	2026-06-05 09:38:27.224	0.2	\N
cmq0qepll01g1hk8dqr16bzre	cmpcfmqag00bohkdzqj6m6c8w	34	C	Genel Test	2026-06-05 09:38:27.224	2026-06-05 09:38:27.224	0.2	\N
cmq0qepll01g2hk8dzwkhever	cmpcfmqag00bohkdzqj6m6c8w	35	A	Genel Test	2026-06-05 09:38:27.224	2026-06-05 09:38:27.224	0.2	\N
cmq0qepll01g3hk8d0ft3bfah	cmpcfmqag00bohkdzqj6m6c8w	36	E	Genel Test	2026-06-05 09:38:27.224	2026-06-05 09:38:27.224	0.2	\N
cmq0qepll01g4hk8d4vr7v9z3	cmpcfmqag00bohkdzqj6m6c8w	37	B	Genel Test	2026-06-05 09:38:27.224	2026-06-05 09:38:27.224	0.2	\N
cmq0qepll01g5hk8dccgjezfk	cmpcfmqag00bohkdzqj6m6c8w	38	B	Genel Test	2026-06-05 09:38:27.224	2026-06-05 09:38:27.224	0.2	\N
cmq0qepll01g6hk8dllo49wnf	cmpcfmqag00bohkdzqj6m6c8w	39	A	Genel Test	2026-06-05 09:38:27.224	2026-06-05 09:38:27.224	0.2	\N
cmq0qepll01g7hk8dt9n9yy1u	cmpcfmqag00bohkdzqj6m6c8w	40	B	Genel Test	2026-06-05 09:38:27.224	2026-06-05 09:38:27.224	0.2	\N
cmq0qg1zf01g8hk8duskebvky	cmpceayuj0002hkdzv7kk1kr6	1	A	Hukuk	2026-06-05 09:39:29.931	2026-06-05 09:39:29.931	0.2	\N
cmq0qg1zf01g9hk8d911v514g	cmpceayuj0002hkdzv7kk1kr6	2	B	Hukuk	2026-06-05 09:39:29.931	2026-06-05 09:39:29.931	0.2	\N
cmq0pkpak00tzhk8dm93wa0oe	cmpxu82qi008chke6zpw3f0ll	40	E	Genel Test	2026-06-05 09:15:07.146	2026-06-05 09:15:07.146	0.2	\N
cmq0pl0m900u0hk8dajfn0wy6	cmpxtxasu004xhke6zparbgm5	1	E	Genel Kültür	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0m900u1hk8ddh4yr9j2	cmpxtxasu004xhke6zparbgm5	2	C	Genel Kültür	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0m900u2hk8dfging3tr	cmpxtxasu004xhke6zparbgm5	3	B	Genel Kültür	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0m900u3hk8dsv1aqv4u	cmpxtxasu004xhke6zparbgm5	4	C	Genel Kültür	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0m900u4hk8drtwosfc8	cmpxtxasu004xhke6zparbgm5	5	E	Genel Kültür	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0m900u5hk8d4d7v6tfz	cmpxtxasu004xhke6zparbgm5	6	C	Genel Kültür	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0m900u6hk8dmomp8gsp	cmpxtxasu004xhke6zparbgm5	7	D	Genel Kültür	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0m900u7hk8dq74ezwex	cmpxtxasu004xhke6zparbgm5	8	D	Genel Kültür	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0m900u8hk8dgj4ihzm2	cmpxtxasu004xhke6zparbgm5	9	A	Genel Kültür	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0m900u9hk8dau67ay0o	cmpxtxasu004xhke6zparbgm5	10	C	Genel Kültür	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0m900uahk8darys0ja3	cmpxtxasu004xhke6zparbgm5	11	C	Genel Kültür	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0m900ubhk8d7e2ouy0j	cmpxtxasu004xhke6zparbgm5	12	A	Genel Kültür	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0m900uchk8dvypkfgkw	cmpxtxasu004xhke6zparbgm5	13	C	Genel Kültür	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0m900udhk8d04r1hbhx	cmpxtxasu004xhke6zparbgm5	14	B	Genel Kültür	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0m900uehk8dzaeyxqzc	cmpxtxasu004xhke6zparbgm5	15	D	Genel Kültür	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0m900ufhk8dbc0zoe1j	cmpxtxasu004xhke6zparbgm5	16	D	Genel Kültür	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0m900ughk8dbr6ahi3m	cmpxtxasu004xhke6zparbgm5	17	C	Genel Kültür	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0m900uhhk8dztya1olb	cmpxtxasu004xhke6zparbgm5	18	E	Genel Kültür	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0m900uihk8dz47xlxdy	cmpxtxasu004xhke6zparbgm5	19	D	Genel Kültür	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0m900ujhk8ddeg5di70	cmpxtxasu004xhke6zparbgm5	20	E	Genel Kültür	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0m900ukhk8digfyrkuo	cmpxtxasu004xhke6zparbgm5	21	D	Genel Kültür	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0m900ulhk8da6d0yy11	cmpxtxasu004xhke6zparbgm5	22	C	Genel Kültür	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0m900umhk8du4zlw027	cmpxtxasu004xhke6zparbgm5	23	C	Genel Kültür	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0m900unhk8dbozqicet	cmpxtxasu004xhke6zparbgm5	24	E	Genel Kültür	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0m900uohk8d8pbvmmdh	cmpxtxasu004xhke6zparbgm5	25	B	Genel Kültür	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0m900uphk8dplmygpqx	cmpxtxasu004xhke6zparbgm5	26	E	Genel Kültür	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0ma00uqhk8dlm6y638b	cmpxtxasu004xhke6zparbgm5	27	B	Genel Kültür	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0ma00urhk8dom00rlnr	cmpxtxasu004xhke6zparbgm5	28	B	Genel Kültür	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0ma00ushk8dqovrdxob	cmpxtxasu004xhke6zparbgm5	29	E	Genel Kültür	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0ma00uthk8dx0oeerv7	cmpxtxasu004xhke6zparbgm5	30	D	Genel Kültür	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0ma00uuhk8de683d38k	cmpxtxasu004xhke6zparbgm5	31	A	Genel Kültür	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0ma00uvhk8dfzbj4z0v	cmpxtxasu004xhke6zparbgm5	32	C	Genel Kültür	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0ma00uwhk8dtn90sxk0	cmpxtxasu004xhke6zparbgm5	33	B	Genel Kültür	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0ma00uxhk8dy8e8z8co	cmpxtxasu004xhke6zparbgm5	34	A	Genel Kültür	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0ma00uyhk8dir8m29cc	cmpxtxasu004xhke6zparbgm5	35	E	Genel Kültür	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0ma00uzhk8du6y9ovop	cmpxtxasu004xhke6zparbgm5	36	E	Genel Kültür	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0ma00v0hk8dljm3j05j	cmpxtxasu004xhke6zparbgm5	37	C	Genel Kültür	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0ma00v1hk8dc5du861t	cmpxtxasu004xhke6zparbgm5	38	D	Genel Kültür	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0ma00v2hk8dvm24lur2	cmpxtxasu004xhke6zparbgm5	39	B	Genel Kültür	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0ma00v3hk8dzx40qwlr	cmpxtxasu004xhke6zparbgm5	40	A	Genel Kültür	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0ma00v4hk8d1dsjg5cp	cmpxtxasu004xhke6zparbgm5	41	D	Genel Kültür	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0ma00v5hk8dpvwcqni9	cmpxtxasu004xhke6zparbgm5	42	E	Genel Kültür	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0ma00v6hk8dbnw3odsh	cmpxtxasu004xhke6zparbgm5	43	A	Genel Kültür	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0ma00v7hk8dettal67u	cmpxtxasu004xhke6zparbgm5	44	D	Genel Kültür	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0ma00v8hk8d8r0w2fx7	cmpxtxasu004xhke6zparbgm5	45	B	Genel Kültür	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0ma00v9hk8dfhhf7a60	cmpxtxasu004xhke6zparbgm5	46	B	Genel Kültür	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0ma00vahk8d8k4yvo2t	cmpxtxasu004xhke6zparbgm5	47	D	Genel Kültür	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0mc00vbhk8djbgfgptj	cmpxtxasu004xhke6zparbgm5	48	E	Genel Kültür	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0mc00vchk8d6sia7jke	cmpxtxasu004xhke6zparbgm5	49	D	Genel Kültür	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0mc00vdhk8d9n72j41b	cmpxtxasu004xhke6zparbgm5	50	A	Genel Kültür	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0mc00vehk8d9ugk0qea	cmpxtxasu004xhke6zparbgm5	51	B	Genel Kültür	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0mc00vfhk8d0pqog09g	cmpxtxasu004xhke6zparbgm5	52	D	Genel Kültür	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0mc00vghk8d3jgjborz	cmpxtxasu004xhke6zparbgm5	53	B	Genel Kültür	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0mc00vhhk8dmilbalm7	cmpxtxasu004xhke6zparbgm5	54	B	Genel Kültür	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0mc00vihk8d9qt7pgbv	cmpxtxasu004xhke6zparbgm5	55	E	Genel Kültür	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0md00vjhk8dfsehm8a1	cmpxtxasu004xhke6zparbgm5	56	E	Genel Kültür	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0md00vkhk8dd4k9tjtp	cmpxtxasu004xhke6zparbgm5	57	D	Genel Kültür	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0md00vlhk8d6ek7i6mv	cmpxtxasu004xhke6zparbgm5	58	B	Genel Kültür	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0md00vmhk8d5gufrugk	cmpxtxasu004xhke6zparbgm5	59	E	Genel Kültür	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0md00vnhk8dfrhl50k3	cmpxtxasu004xhke6zparbgm5	60	E	Genel Kültür	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0md00vohk8d4pkoyxzi	cmpxtxasu004xhke6zparbgm5	61	C	Genel Yetenek	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0md00vphk8d3qb6zg8o	cmpxtxasu004xhke6zparbgm5	62	A	Genel Yetenek	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0md00vqhk8dqft3mt7h	cmpxtxasu004xhke6zparbgm5	63	D	Genel Yetenek	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0md00vrhk8dvqsxuvi0	cmpxtxasu004xhke6zparbgm5	64	B	Genel Yetenek	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0md00vshk8dx85unn6y	cmpxtxasu004xhke6zparbgm5	65	C	Genel Yetenek	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0md00vthk8dpg04s01c	cmpxtxasu004xhke6zparbgm5	66	C	Genel Yetenek	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0md00vuhk8dognxgmwt	cmpxtxasu004xhke6zparbgm5	67	B	Genel Yetenek	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0md00vvhk8do0kw14ev	cmpxtxasu004xhke6zparbgm5	68	E	Genel Yetenek	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0md00vwhk8dwukw2jqh	cmpxtxasu004xhke6zparbgm5	69	A	Genel Yetenek	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0md00vxhk8d9vvfig6n	cmpxtxasu004xhke6zparbgm5	70	A	Genel Yetenek	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0md00vyhk8do13wbvgr	cmpxtxasu004xhke6zparbgm5	71	A	Genel Yetenek	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0md00vzhk8d50gl5xpx	cmpxtxasu004xhke6zparbgm5	72	E	Genel Yetenek	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0md00w0hk8dk32uxudx	cmpxtxasu004xhke6zparbgm5	73	C	Genel Yetenek	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0md00w1hk8dg3l3yf80	cmpxtxasu004xhke6zparbgm5	74	E	Genel Yetenek	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0md00w2hk8dhzvnim50	cmpxtxasu004xhke6zparbgm5	75	B	Genel Yetenek	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0md00w3hk8dvl85ag58	cmpxtxasu004xhke6zparbgm5	76	D	Genel Yetenek	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0md00w4hk8ddeb8p21w	cmpxtxasu004xhke6zparbgm5	77	D	Genel Yetenek	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0md00w5hk8d3t74puu0	cmpxtxasu004xhke6zparbgm5	78	A	Genel Yetenek	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0md00w6hk8dwa9r9ptl	cmpxtxasu004xhke6zparbgm5	79	C	Genel Yetenek	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0md00w7hk8den4k5z90	cmpxtxasu004xhke6zparbgm5	80	D	Genel Yetenek	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0md00w8hk8dgzotzhtq	cmpxtxasu004xhke6zparbgm5	81	E	Genel Yetenek	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0md00w9hk8d55pfnt07	cmpxtxasu004xhke6zparbgm5	82	C	Genel Yetenek	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0md00wahk8dp4f73d21	cmpxtxasu004xhke6zparbgm5	83	E	Genel Yetenek	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0md00wbhk8dyn3j0ezs	cmpxtxasu004xhke6zparbgm5	84	D	Genel Yetenek	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0md00wchk8dlsxgsj1s	cmpxtxasu004xhke6zparbgm5	85	B	Genel Yetenek	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0md00wdhk8dok7cje7h	cmpxtxasu004xhke6zparbgm5	86	E	Genel Yetenek	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0md00wehk8dl6t34ml2	cmpxtxasu004xhke6zparbgm5	87	D	Genel Yetenek	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0md00wfhk8dbrf45nd2	cmpxtxasu004xhke6zparbgm5	88	D	Genel Yetenek	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0me00wghk8dr0qhz3sa	cmpxtxasu004xhke6zparbgm5	89	A	Genel Yetenek	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0me00whhk8dphjzhd52	cmpxtxasu004xhke6zparbgm5	90	C	Genel Yetenek	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0me00wihk8dcqou6b6p	cmpxtxasu004xhke6zparbgm5	91	D	Genel Yetenek	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0me00wjhk8dkdw18n1y	cmpxtxasu004xhke6zparbgm5	92	A	Genel Yetenek	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0me00wkhk8d13vxmo87	cmpxtxasu004xhke6zparbgm5	93	B	Genel Yetenek	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0me00wlhk8d7vrc42qr	cmpxtxasu004xhke6zparbgm5	94	A	Genel Yetenek	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0me00wmhk8dxfub49ap	cmpxtxasu004xhke6zparbgm5	95	D	Genel Yetenek	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0me00wnhk8dnbsbek9g	cmpxtxasu004xhke6zparbgm5	96	A	Genel Yetenek	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0me00wohk8dscd7hva6	cmpxtxasu004xhke6zparbgm5	97	A	Genel Yetenek	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0me00wphk8d9qa769me	cmpxtxasu004xhke6zparbgm5	98	D	Genel Yetenek	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0me00wqhk8d4fdbs8zs	cmpxtxasu004xhke6zparbgm5	99	C	Genel Yetenek	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0me00wrhk8d5i2mrfcz	cmpxtxasu004xhke6zparbgm5	100	D	Genel Yetenek	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0me00wshk8doiq5178p	cmpxtxasu004xhke6zparbgm5	101	C	Genel Yetenek	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0me00wthk8delj9t5ws	cmpxtxasu004xhke6zparbgm5	102	B	Genel Yetenek	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0me00wuhk8duj26r7t7	cmpxtxasu004xhke6zparbgm5	103	D	Genel Yetenek	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0me00wvhk8dfl89ytyo	cmpxtxasu004xhke6zparbgm5	104	D	Genel Yetenek	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0me00wwhk8d85ve8wur	cmpxtxasu004xhke6zparbgm5	105	D	Genel Yetenek	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0me00wxhk8dwabelej4	cmpxtxasu004xhke6zparbgm5	106	C	Genel Yetenek	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0me00wyhk8dwfhqj4n0	cmpxtxasu004xhke6zparbgm5	107	B	Genel Yetenek	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0me00wzhk8dr0mk10q7	cmpxtxasu004xhke6zparbgm5	108	C	Genel Yetenek	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0me00x0hk8dhnvtjfbj	cmpxtxasu004xhke6zparbgm5	109	B	Genel Yetenek	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0me00x1hk8d2y8ytimo	cmpxtxasu004xhke6zparbgm5	110	E	Genel Yetenek	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0me00x2hk8d2ng1yyh5	cmpxtxasu004xhke6zparbgm5	111	C	Genel Yetenek	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0me00x3hk8dildrp799	cmpxtxasu004xhke6zparbgm5	112	C	Genel Yetenek	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0me00x4hk8dwknly25s	cmpxtxasu004xhke6zparbgm5	113	B	Genel Yetenek	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0me00x5hk8d256bdoqj	cmpxtxasu004xhke6zparbgm5	114	D	Genel Yetenek	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0me00x6hk8d48rkcugt	cmpxtxasu004xhke6zparbgm5	115	A	Genel Yetenek	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0me00x7hk8dml3fc850	cmpxtxasu004xhke6zparbgm5	116	A	Genel Yetenek	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0me00x8hk8dv6i0lr2z	cmpxtxasu004xhke6zparbgm5	117	B	Genel Yetenek	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0me00x9hk8dlq6xtjfh	cmpxtxasu004xhke6zparbgm5	118	D	Genel Yetenek	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0me00xahk8ds6xwcfka	cmpxtxasu004xhke6zparbgm5	119	B	Genel Yetenek	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pl0me00xbhk8dlwe2d5q1	cmpxtxasu004xhke6zparbgm5	120	C	Genel Yetenek	2026-06-05 09:15:21.821	2026-06-05 09:15:21.821	0.1	\N
cmq0pldda00xchk8dps861mv2	cmpxui50s009jhke63ury65bc	1	E	Genel Test	2026-06-05 09:15:38.35	2026-06-05 09:15:38.35	0.1	\N
cmq0pldda00xdhk8dzdy1dqrx	cmpxui50s009jhke63ury65bc	2	C	Genel Test	2026-06-05 09:15:38.35	2026-06-05 09:15:38.35	0.1	\N
cmq0qg1zf01gahk8drker89h5	cmpceayuj0002hkdzv7kk1kr6	3	E	Hukuk	2026-06-05 09:39:29.931	2026-06-05 09:39:29.931	0.2	\N
cmq0qg1zf01gbhk8dqn4jex6h	cmpceayuj0002hkdzv7kk1kr6	4	A	Hukuk	2026-06-05 09:39:29.931	2026-06-05 09:39:29.931	0.2	\N
cmq0qg1zf01gchk8d2islhhlt	cmpceayuj0002hkdzv7kk1kr6	5	C	Hukuk	2026-06-05 09:39:29.931	2026-06-05 09:39:29.931	0.2	\N
cmq0qg1zf01gdhk8dnfth4882	cmpceayuj0002hkdzv7kk1kr6	6	C	Hukuk	2026-06-05 09:39:29.931	2026-06-05 09:39:29.931	0.2	\N
cmq0qg1zf01gehk8dl0d9u7sz	cmpceayuj0002hkdzv7kk1kr6	7	B	Hukuk	2026-06-05 09:39:29.931	2026-06-05 09:39:29.931	0.2	\N
cmq0qg1zf01gfhk8dxzu8h8sh	cmpceayuj0002hkdzv7kk1kr6	8	C	Hukuk	2026-06-05 09:39:29.931	2026-06-05 09:39:29.931	0.2	\N
cmq0qg1zf01gghk8d53jdytk5	cmpceayuj0002hkdzv7kk1kr6	9	C	Hukuk	2026-06-05 09:39:29.931	2026-06-05 09:39:29.931	0.2	\N
cmq0qg1zf01ghhk8dv52l5yna	cmpceayuj0002hkdzv7kk1kr6	10	B	Hukuk	2026-06-05 09:39:29.931	2026-06-05 09:39:29.931	0.2	\N
cmq0qg1zf01gihk8ddp8hv9ur	cmpceayuj0002hkdzv7kk1kr6	11	D	Hukuk	2026-06-05 09:39:29.931	2026-06-05 09:39:29.931	0.2	\N
cmq0qg1zf01gjhk8dedv5hoqp	cmpceayuj0002hkdzv7kk1kr6	12	C	Hukuk	2026-06-05 09:39:29.931	2026-06-05 09:39:29.931	0.2	\N
cmq0qg1zf01gkhk8dagoc7jnb	cmpceayuj0002hkdzv7kk1kr6	13	B	Hukuk	2026-06-05 09:39:29.931	2026-06-05 09:39:29.931	0.2	\N
cmq0qg1zf01glhk8dzuka44zt	cmpceayuj0002hkdzv7kk1kr6	14	D	Hukuk	2026-06-05 09:39:29.931	2026-06-05 09:39:29.931	0.2	\N
cmq0qg1zf01gmhk8dsj66pg71	cmpceayuj0002hkdzv7kk1kr6	15	B	Hukuk	2026-06-05 09:39:29.931	2026-06-05 09:39:29.931	0.2	\N
cmq0qg1zf01gnhk8damjpyb9r	cmpceayuj0002hkdzv7kk1kr6	16	E	Hukuk	2026-06-05 09:39:29.931	2026-06-05 09:39:29.931	0.2	\N
cmq0qg1zf01gohk8dgo5u3y3p	cmpceayuj0002hkdzv7kk1kr6	17	D	Hukuk	2026-06-05 09:39:29.931	2026-06-05 09:39:29.931	0.2	\N
cmq0qg1zf01gphk8dzeoln07c	cmpceayuj0002hkdzv7kk1kr6	18	E	Hukuk	2026-06-05 09:39:29.931	2026-06-05 09:39:29.931	0.2	\N
cmq0qg1zf01gqhk8dezlencva	cmpceayuj0002hkdzv7kk1kr6	19	B	Hukuk	2026-06-05 09:39:29.931	2026-06-05 09:39:29.931	0.2	\N
cmq0qg1zf01grhk8d1waqiva3	cmpceayuj0002hkdzv7kk1kr6	20	B	Hukuk	2026-06-05 09:39:29.931	2026-06-05 09:39:29.931	0.2	\N
cmq0qg1zf01gshk8d6pdkkyd2	cmpceayuj0002hkdzv7kk1kr6	21	A	Hukuk	2026-06-05 09:39:29.931	2026-06-05 09:39:29.931	0.2	\N
cmq0qg1zf01gthk8dpvw1qgzn	cmpceayuj0002hkdzv7kk1kr6	22	D	Hukuk	2026-06-05 09:39:29.931	2026-06-05 09:39:29.931	0.2	\N
cmq0qg1zf01guhk8dh0ks78pn	cmpceayuj0002hkdzv7kk1kr6	23	B	Hukuk	2026-06-05 09:39:29.931	2026-06-05 09:39:29.931	0.2	\N
cmq0qg1zf01gvhk8ddi26ckdt	cmpceayuj0002hkdzv7kk1kr6	24	A	Hukuk	2026-06-05 09:39:29.931	2026-06-05 09:39:29.931	0.2	\N
cmq0qg1zf01gwhk8dutkwg9mr	cmpceayuj0002hkdzv7kk1kr6	25	A	Hukuk	2026-06-05 09:39:29.931	2026-06-05 09:39:29.931	0.2	\N
cmq0qg1zf01gxhk8dpxccoyow	cmpceayuj0002hkdzv7kk1kr6	26	B	Hukuk	2026-06-05 09:39:29.931	2026-06-05 09:39:29.931	0.2	\N
cmq0qg1zg01gyhk8di2kotbub	cmpceayuj0002hkdzv7kk1kr6	27	D	Hukuk	2026-06-05 09:39:29.931	2026-06-05 09:39:29.931	0.2	\N
cmq0qg1zg01gzhk8dmc4ys74i	cmpceayuj0002hkdzv7kk1kr6	28	D	Hukuk	2026-06-05 09:39:29.931	2026-06-05 09:39:29.931	0.2	\N
cmq0qg1zg01h0hk8drw7udf1f	cmpceayuj0002hkdzv7kk1kr6	29	C	Hukuk	2026-06-05 09:39:29.931	2026-06-05 09:39:29.931	0.2	\N
cmq0qg1zg01h1hk8d4927vcvs	cmpceayuj0002hkdzv7kk1kr6	30	A	Hukuk	2026-06-05 09:39:29.931	2026-06-05 09:39:29.931	0.2	\N
cmq0qg1zg01h2hk8dyz13sqiv	cmpceayuj0002hkdzv7kk1kr6	31	A	Hukuk	2026-06-05 09:39:29.931	2026-06-05 09:39:29.931	0.2	\N
cmq0qg1zg01h3hk8dnnrk2l0z	cmpceayuj0002hkdzv7kk1kr6	32	E	Hukuk	2026-06-05 09:39:29.931	2026-06-05 09:39:29.931	0.2	\N
cmq0qg1zg01h4hk8dtp7r3rd4	cmpceayuj0002hkdzv7kk1kr6	33	D	Hukuk	2026-06-05 09:39:29.931	2026-06-05 09:39:29.931	0.2	\N
cmq0qg1zg01h5hk8disyu5jev	cmpceayuj0002hkdzv7kk1kr6	34	D	Hukuk	2026-06-05 09:39:29.931	2026-06-05 09:39:29.931	0.2	\N
cmq0qg1zg01h6hk8dwzx02gz1	cmpceayuj0002hkdzv7kk1kr6	35	B	Hukuk	2026-06-05 09:39:29.931	2026-06-05 09:39:29.931	0.2	\N
cmq0qg1zg01h7hk8dy664a9kt	cmpceayuj0002hkdzv7kk1kr6	36	A	Hukuk	2026-06-05 09:39:29.931	2026-06-05 09:39:29.931	0.2	\N
cmq0qg1zg01h8hk8d8po3d49a	cmpceayuj0002hkdzv7kk1kr6	37	C	Hukuk	2026-06-05 09:39:29.931	2026-06-05 09:39:29.931	0.2	\N
cmq0qg1zg01h9hk8dd5k9yv75	cmpceayuj0002hkdzv7kk1kr6	38	C	Hukuk	2026-06-05 09:39:29.931	2026-06-05 09:39:29.931	0.2	\N
cmq0qg1zg01hahk8dxtet6vez	cmpceayuj0002hkdzv7kk1kr6	39	D	Hukuk	2026-06-05 09:39:29.931	2026-06-05 09:39:29.931	0.2	\N
cmq0qg1zg01hbhk8dbg96ys6s	cmpceayuj0002hkdzv7kk1kr6	40	B	Hukuk	2026-06-05 09:39:29.931	2026-06-05 09:39:29.931	0.2	\N
cmq0qgwyc01hchk8d4c488vih	cmpceulay004rhkdzau8ylxgo	1	B	Muhasebe	2026-06-05 09:40:10.068	2026-06-05 09:40:10.068	0.2	\N
cmq0qgwyc01hdhk8d01fr9605	cmpceulay004rhkdzau8ylxgo	2	B	Muhasebe	2026-06-05 09:40:10.068	2026-06-05 09:40:10.068	0.2	\N
cmq0pldda00xehk8dzhsvx7n4	cmpxui50s009jhke63ury65bc	3	A	Genel Test	2026-06-05 09:15:38.35	2026-06-05 09:15:38.35	0.1	\N
cmq0pldda00xfhk8dcrswkwix	cmpxui50s009jhke63ury65bc	4	D	Genel Test	2026-06-05 09:15:38.35	2026-06-05 09:15:38.35	0.1	\N
cmq0pldda00xghk8d0jysvhjd	cmpxui50s009jhke63ury65bc	5	C	Genel Test	2026-06-05 09:15:38.35	2026-06-05 09:15:38.35	0.1	\N
cmq0pldda00xhhk8d0pkj7402	cmpxui50s009jhke63ury65bc	6	C	Genel Test	2026-06-05 09:15:38.35	2026-06-05 09:15:38.35	0.1	\N
cmq0pldda00xihk8dyy14of0r	cmpxui50s009jhke63ury65bc	7	B	Genel Test	2026-06-05 09:15:38.35	2026-06-05 09:15:38.35	0.1	\N
cmq0pldda00xjhk8dl6v5awd4	cmpxui50s009jhke63ury65bc	8	D	Genel Test	2026-06-05 09:15:38.35	2026-06-05 09:15:38.35	0.1	\N
cmq0pldda00xkhk8dqmovogua	cmpxui50s009jhke63ury65bc	9	E	Genel Test	2026-06-05 09:15:38.35	2026-06-05 09:15:38.35	0.1	\N
cmq0pldda00xlhk8dq6yhvefv	cmpxui50s009jhke63ury65bc	10	A	Genel Test	2026-06-05 09:15:38.35	2026-06-05 09:15:38.35	0.1	\N
cmq0pldda00xmhk8dsx63ejfa	cmpxui50s009jhke63ury65bc	11	C	Genel Test	2026-06-05 09:15:38.35	2026-06-05 09:15:38.35	0.1	\N
cmq0pldda00xnhk8d34iiskzu	cmpxui50s009jhke63ury65bc	12	E	Genel Test	2026-06-05 09:15:38.35	2026-06-05 09:15:38.35	0.1	\N
cmq0pldda00xohk8dxubhk9gp	cmpxui50s009jhke63ury65bc	13	E	Genel Test	2026-06-05 09:15:38.35	2026-06-05 09:15:38.35	0.1	\N
cmq0pldda00xphk8da0wrjnu2	cmpxui50s009jhke63ury65bc	14	D	Genel Test	2026-06-05 09:15:38.35	2026-06-05 09:15:38.35	0.1	\N
cmq0pldda00xqhk8dn8iewa4b	cmpxui50s009jhke63ury65bc	15	C	Genel Test	2026-06-05 09:15:38.35	2026-06-05 09:15:38.35	0.1	\N
cmq0pldda00xrhk8d4kr5gcxl	cmpxui50s009jhke63ury65bc	16	E	Genel Test	2026-06-05 09:15:38.35	2026-06-05 09:15:38.35	0.1	\N
cmq0pldda00xshk8dqhfunn8w	cmpxui50s009jhke63ury65bc	17	B	Genel Test	2026-06-05 09:15:38.35	2026-06-05 09:15:38.35	0.1	\N
cmq0qgwyc01hehk8deirer77f	cmpceulay004rhkdzau8ylxgo	3	B	Muhasebe	2026-06-05 09:40:10.068	2026-06-05 09:40:10.068	0.2	\N
cmq0qgwyc01hfhk8dkin6z26p	cmpceulay004rhkdzau8ylxgo	4	C	Muhasebe	2026-06-05 09:40:10.068	2026-06-05 09:40:10.068	0.2	\N
cmq0qgwyc01hghk8d2ie718yv	cmpceulay004rhkdzau8ylxgo	5	E	Muhasebe	2026-06-05 09:40:10.068	2026-06-05 09:40:10.068	0.2	\N
cmq0pldda00xthk8dtg3vf2oz	cmpxui50s009jhke63ury65bc	18	E	Genel Test	2026-06-05 09:15:38.35	2026-06-05 09:15:38.35	0.1	\N
cmq0pldda00xuhk8d2wi9ur33	cmpxui50s009jhke63ury65bc	19	D	Genel Test	2026-06-05 09:15:38.35	2026-06-05 09:15:38.35	0.1	\N
cmq0pldda00xvhk8dap1krwey	cmpxui50s009jhke63ury65bc	20	B	Genel Test	2026-06-05 09:15:38.35	2026-06-05 09:15:38.35	0.1	\N
cmq0pldda00xwhk8d4zygpulk	cmpxui50s009jhke63ury65bc	21	D	Genel Test	2026-06-05 09:15:38.35	2026-06-05 09:15:38.35	0.1	\N
cmq0pldda00xxhk8d9cuvut4l	cmpxui50s009jhke63ury65bc	22	B	Genel Test	2026-06-05 09:15:38.35	2026-06-05 09:15:38.35	0.1	\N
cmq0pldda00xyhk8d0oyirmqq	cmpxui50s009jhke63ury65bc	23	C	Genel Test	2026-06-05 09:15:38.35	2026-06-05 09:15:38.35	0.1	\N
cmq0plddb00xzhk8dzy7ie4cs	cmpxui50s009jhke63ury65bc	24	B	Genel Test	2026-06-05 09:15:38.35	2026-06-05 09:15:38.35	0.1	\N
cmq0plddb00y0hk8dc1uqbrtz	cmpxui50s009jhke63ury65bc	25	D	Genel Test	2026-06-05 09:15:38.35	2026-06-05 09:15:38.35	0.1	\N
cmq0plddb00y1hk8dbu4k1dyr	cmpxui50s009jhke63ury65bc	26	B	Genel Test	2026-06-05 09:15:38.35	2026-06-05 09:15:38.35	0.1	\N
cmq0plddb00y2hk8dms09k27n	cmpxui50s009jhke63ury65bc	27	B	Genel Test	2026-06-05 09:15:38.35	2026-06-05 09:15:38.35	0.1	\N
cmq0plddb00y3hk8dpumxe3aw	cmpxui50s009jhke63ury65bc	28	D	Genel Test	2026-06-05 09:15:38.35	2026-06-05 09:15:38.35	0.1	\N
cmq0plddb00y4hk8dnu5ygjoy	cmpxui50s009jhke63ury65bc	29	A	Genel Test	2026-06-05 09:15:38.35	2026-06-05 09:15:38.35	0.1	\N
cmq0plddb00y5hk8dy7l3ra3h	cmpxui50s009jhke63ury65bc	30	C	Genel Test	2026-06-05 09:15:38.35	2026-06-05 09:15:38.35	0.1	\N
cmq0plddb00y6hk8dysswyx7c	cmpxui50s009jhke63ury65bc	31	D	Genel Test	2026-06-05 09:15:38.35	2026-06-05 09:15:38.35	0.1	\N
cmq0plddb00y7hk8ddcge07v2	cmpxui50s009jhke63ury65bc	32	E	Genel Test	2026-06-05 09:15:38.35	2026-06-05 09:15:38.35	0.1	\N
cmq0plddb00y8hk8dl7x5c83n	cmpxui50s009jhke63ury65bc	33	D	Genel Test	2026-06-05 09:15:38.35	2026-06-05 09:15:38.35	0.1	\N
cmq0plddb00y9hk8dc7qrleti	cmpxui50s009jhke63ury65bc	34	A	Genel Test	2026-06-05 09:15:38.35	2026-06-05 09:15:38.35	0.1	\N
cmq0plddb00yahk8dysionblf	cmpxui50s009jhke63ury65bc	35	A	Genel Test	2026-06-05 09:15:38.35	2026-06-05 09:15:38.35	0.1	\N
cmq0plddb00ybhk8doot38469	cmpxui50s009jhke63ury65bc	36	E	Genel Test	2026-06-05 09:15:38.35	2026-06-05 09:15:38.35	0.1	\N
cmq0plddb00ychk8dt82jg1bs	cmpxui50s009jhke63ury65bc	37	A	Genel Test	2026-06-05 09:15:38.35	2026-06-05 09:15:38.35	0.1	\N
cmq0plddb00ydhk8dz2ngpsfv	cmpxui50s009jhke63ury65bc	38	C	Genel Test	2026-06-05 09:15:38.35	2026-06-05 09:15:38.35	0.1	\N
cmq0plddb00yehk8d5ei26vtw	cmpxui50s009jhke63ury65bc	39	D	Genel Test	2026-06-05 09:15:38.35	2026-06-05 09:15:38.35	0.1	\N
cmq0plddb00yfhk8djfr1hj5g	cmpxui50s009jhke63ury65bc	40	B	Genel Test	2026-06-05 09:15:38.35	2026-06-05 09:15:38.35	0.1	\N
cmq0qgwyc01hhhk8dhusblbxx	cmpceulay004rhkdzau8ylxgo	6	A	Muhasebe	2026-06-05 09:40:10.068	2026-06-05 09:40:10.068	0.2	\N
cmq0qgwyc01hihk8dpjizth83	cmpceulay004rhkdzau8ylxgo	7	E	Muhasebe	2026-06-05 09:40:10.068	2026-06-05 09:40:10.068	0.2	\N
cmq0qgwyd01hjhk8dcohdrrmy	cmpceulay004rhkdzau8ylxgo	8	C	Muhasebe	2026-06-05 09:40:10.068	2026-06-05 09:40:10.068	0.2	\N
cmq0qgwyd01hkhk8dzsgiwqu8	cmpceulay004rhkdzau8ylxgo	9	C	Muhasebe	2026-06-05 09:40:10.068	2026-06-05 09:40:10.068	0.2	\N
cmq0qgwyd01hlhk8d48nxeu4i	cmpceulay004rhkdzau8ylxgo	10	A	Muhasebe	2026-06-05 09:40:10.068	2026-06-05 09:40:10.068	0.2	\N
cmq0qgwyd01hmhk8dkvdx2itf	cmpceulay004rhkdzau8ylxgo	11	B	Muhasebe	2026-06-05 09:40:10.068	2026-06-05 09:40:10.068	0.2	\N
cmq0qgwyd01hnhk8dt7tjhgfr	cmpceulay004rhkdzau8ylxgo	12	D	Muhasebe	2026-06-05 09:40:10.068	2026-06-05 09:40:10.068	0.2	\N
cmq0qgwyd01hohk8d8e09yxyp	cmpceulay004rhkdzau8ylxgo	13	B	Muhasebe	2026-06-05 09:40:10.068	2026-06-05 09:40:10.068	0.2	\N
cmq0qgwyd01hphk8dgqpq5qwy	cmpceulay004rhkdzau8ylxgo	14	D	Muhasebe	2026-06-05 09:40:10.068	2026-06-05 09:40:10.068	0.2	\N
cmq0qgwyd01hqhk8diu319cit	cmpceulay004rhkdzau8ylxgo	15	B	Muhasebe	2026-06-05 09:40:10.068	2026-06-05 09:40:10.068	0.2	\N
cmq0qgwyd01hrhk8dt6h6yjtr	cmpceulay004rhkdzau8ylxgo	16	A	Muhasebe	2026-06-05 09:40:10.068	2026-06-05 09:40:10.068	0.2	\N
cmq0qgwyd01hshk8ddxoq6zck	cmpceulay004rhkdzau8ylxgo	17	C	Muhasebe	2026-06-05 09:40:10.068	2026-06-05 09:40:10.068	0.2	\N
cmq0qgwyd01hthk8du0yvjrlj	cmpceulay004rhkdzau8ylxgo	18	D	Muhasebe	2026-06-05 09:40:10.068	2026-06-05 09:40:10.068	0.2	\N
cmq0qgwyd01huhk8d3742q6aa	cmpceulay004rhkdzau8ylxgo	19	B	Muhasebe	2026-06-05 09:40:10.068	2026-06-05 09:40:10.068	0.2	\N
cmq0qgwyd01hvhk8dkcz66b89	cmpceulay004rhkdzau8ylxgo	20	A	Muhasebe	2026-06-05 09:40:10.068	2026-06-05 09:40:10.068	0.2	\N
cmq0qgwyd01hwhk8dazdoko4x	cmpceulay004rhkdzau8ylxgo	21	C	Muhasebe	2026-06-05 09:40:10.068	2026-06-05 09:40:10.068	0.2	\N
cmq0qgwyd01hxhk8dqdltd76v	cmpceulay004rhkdzau8ylxgo	22	C	Muhasebe	2026-06-05 09:40:10.068	2026-06-05 09:40:10.068	0.2	\N
cmq0qgwyd01hyhk8d91gqac4w	cmpceulay004rhkdzau8ylxgo	23	C	Muhasebe	2026-06-05 09:40:10.068	2026-06-05 09:40:10.068	0.2	\N
cmq0qgwyd01hzhk8dnlgbw57e	cmpceulay004rhkdzau8ylxgo	24	D	Muhasebe	2026-06-05 09:40:10.068	2026-06-05 09:40:10.068	0.2	\N
cmq0qgwyd01i0hk8diesp1mlw	cmpceulay004rhkdzau8ylxgo	25	C	Muhasebe	2026-06-05 09:40:10.068	2026-06-05 09:40:10.068	0.2	\N
cmq0qgwyd01i1hk8d30co22mg	cmpceulay004rhkdzau8ylxgo	26	B	Muhasebe	2026-06-05 09:40:10.068	2026-06-05 09:40:10.068	0.2	\N
cmq0qgwyd01i2hk8dlznogdkq	cmpceulay004rhkdzau8ylxgo	27	C	Muhasebe	2026-06-05 09:40:10.068	2026-06-05 09:40:10.068	0.2	\N
cmq0qgwyd01i3hk8drqubxup2	cmpceulay004rhkdzau8ylxgo	28	C	Muhasebe	2026-06-05 09:40:10.068	2026-06-05 09:40:10.068	0.2	\N
cmq0qgwyd01i4hk8dr9obqghj	cmpceulay004rhkdzau8ylxgo	29	C	Muhasebe	2026-06-05 09:40:10.068	2026-06-05 09:40:10.068	0.2	\N
cmq0qgwyd01i5hk8diruq4ksk	cmpceulay004rhkdzau8ylxgo	30	A	Muhasebe	2026-06-05 09:40:10.068	2026-06-05 09:40:10.068	0.2	\N
cmq0qgwyd01i6hk8dv179pqvg	cmpceulay004rhkdzau8ylxgo	31	C	Muhasebe	2026-06-05 09:40:10.068	2026-06-05 09:40:10.068	0.2	\N
cmq0qgwyd01i7hk8d6m46ltwm	cmpceulay004rhkdzau8ylxgo	32	B	Muhasebe	2026-06-05 09:40:10.068	2026-06-05 09:40:10.068	0.2	\N
cmq0qgwyd01i8hk8dbg2uqt5m	cmpceulay004rhkdzau8ylxgo	33	A	Muhasebe	2026-06-05 09:40:10.068	2026-06-05 09:40:10.068	0.2	\N
cmq0qgwyd01i9hk8dy5icaxtb	cmpceulay004rhkdzau8ylxgo	34	D	Muhasebe	2026-06-05 09:40:10.068	2026-06-05 09:40:10.068	0.2	\N
cmq0qgwyd01iahk8dxbz3a6gi	cmpceulay004rhkdzau8ylxgo	35	E	Muhasebe	2026-06-05 09:40:10.068	2026-06-05 09:40:10.068	0.2	\N
cmq0qgwyd01ibhk8dju1qymd6	cmpceulay004rhkdzau8ylxgo	36	A	Muhasebe	2026-06-05 09:40:10.068	2026-06-05 09:40:10.068	0.2	\N
cmq0qgwyd01ichk8d28xr3c7m	cmpceulay004rhkdzau8ylxgo	37	C	Muhasebe	2026-06-05 09:40:10.068	2026-06-05 09:40:10.068	0.2	\N
cmq0qgwyd01idhk8dselgxvqi	cmpceulay004rhkdzau8ylxgo	38	C	Muhasebe	2026-06-05 09:40:10.068	2026-06-05 09:40:10.068	0.2	\N
cmq0qgwyd01iehk8dir3dvi4i	cmpceulay004rhkdzau8ylxgo	39	C	Muhasebe	2026-06-05 09:40:10.068	2026-06-05 09:40:10.068	0.2	\N
cmq0qgwyd01ifhk8daydqeouw	cmpceulay004rhkdzau8ylxgo	40	B	Muhasebe	2026-06-05 09:40:10.068	2026-06-05 09:40:10.068	0.2	\N
cmq0plwtr00yghk8d6wei9482	cmpxsu9qy003phke65kkykwv8	1	C	Genel Test	2026-06-05 09:16:03.567	2026-06-05 09:16:03.567	0.2	\N
cmq0plwtr00yhhk8dm3xgtin9	cmpxsu9qy003phke65kkykwv8	2	E	Genel Test	2026-06-05 09:16:03.567	2026-06-05 09:16:03.567	0.2	\N
cmq0plwtr00yihk8die73n31z	cmpxsu9qy003phke65kkykwv8	3	E	Genel Test	2026-06-05 09:16:03.567	2026-06-05 09:16:03.567	0.2	\N
cmq0plwtr00yjhk8dm5dqvtl1	cmpxsu9qy003phke65kkykwv8	4	D	Genel Test	2026-06-05 09:16:03.567	2026-06-05 09:16:03.567	0.2	\N
cmq0plwtr00ykhk8ds64knzwf	cmpxsu9qy003phke65kkykwv8	5	A	Genel Test	2026-06-05 09:16:03.567	2026-06-05 09:16:03.567	0.2	\N
cmq0plwts00ylhk8dykzlmhho	cmpxsu9qy003phke65kkykwv8	6	E	Genel Test	2026-06-05 09:16:03.567	2026-06-05 09:16:03.567	0.2	\N
cmq0plwts00ymhk8dum7814it	cmpxsu9qy003phke65kkykwv8	7	D	Genel Test	2026-06-05 09:16:03.567	2026-06-05 09:16:03.567	0.2	\N
cmq0plwts00ynhk8dtwvva0ee	cmpxsu9qy003phke65kkykwv8	8	D	Genel Test	2026-06-05 09:16:03.567	2026-06-05 09:16:03.567	0.2	\N
cmq0plwts00yohk8dmjbhb1br	cmpxsu9qy003phke65kkykwv8	9	C	Genel Test	2026-06-05 09:16:03.567	2026-06-05 09:16:03.567	0.2	\N
cmq0plwts00yphk8d7hkbib1b	cmpxsu9qy003phke65kkykwv8	10	B	Genel Test	2026-06-05 09:16:03.567	2026-06-05 09:16:03.567	0.2	\N
cmq0plwts00yqhk8d1e6549t5	cmpxsu9qy003phke65kkykwv8	11	E	Genel Test	2026-06-05 09:16:03.567	2026-06-05 09:16:03.567	0.2	\N
cmq0plwts00yrhk8dkbywbe55	cmpxsu9qy003phke65kkykwv8	12	D	Genel Test	2026-06-05 09:16:03.567	2026-06-05 09:16:03.567	0.2	\N
cmq0plwts00yshk8dq5e0z1md	cmpxsu9qy003phke65kkykwv8	13	C	Genel Test	2026-06-05 09:16:03.567	2026-06-05 09:16:03.567	0.2	\N
cmq0plwts00ythk8dxi1g6895	cmpxsu9qy003phke65kkykwv8	14	C	Genel Test	2026-06-05 09:16:03.567	2026-06-05 09:16:03.567	0.2	\N
cmq0plwts00yuhk8dl0l4geyg	cmpxsu9qy003phke65kkykwv8	15	D	Genel Test	2026-06-05 09:16:03.567	2026-06-05 09:16:03.567	0.2	\N
cmq0plwts00yvhk8djbs0wuqc	cmpxsu9qy003phke65kkykwv8	16	E	Genel Test	2026-06-05 09:16:03.567	2026-06-05 09:16:03.567	0.2	\N
cmq0plwts00ywhk8dbpvehsb2	cmpxsu9qy003phke65kkykwv8	17	E	Genel Test	2026-06-05 09:16:03.567	2026-06-05 09:16:03.567	0.2	\N
cmq0plwts00yxhk8dh2qzcvrw	cmpxsu9qy003phke65kkykwv8	18	E	Genel Test	2026-06-05 09:16:03.567	2026-06-05 09:16:03.567	0.2	\N
cmq0plwts00yyhk8d0fe76zrm	cmpxsu9qy003phke65kkykwv8	19	E	Genel Test	2026-06-05 09:16:03.567	2026-06-05 09:16:03.567	0.2	\N
cmq0plwts00yzhk8dhccnlgpd	cmpxsu9qy003phke65kkykwv8	20	E	Genel Test	2026-06-05 09:16:03.567	2026-06-05 09:16:03.567	0.2	\N
cmq0plwts00z0hk8dgdmfj8ki	cmpxsu9qy003phke65kkykwv8	21	B	Genel Test	2026-06-05 09:16:03.567	2026-06-05 09:16:03.567	0.2	\N
cmq0plwts00z1hk8d3sg3080b	cmpxsu9qy003phke65kkykwv8	22	A	Genel Test	2026-06-05 09:16:03.567	2026-06-05 09:16:03.567	0.2	\N
cmq0plwts00z2hk8dazd0glt7	cmpxsu9qy003phke65kkykwv8	23	C	Genel Test	2026-06-05 09:16:03.567	2026-06-05 09:16:03.567	0.2	\N
cmq0plwts00z3hk8dknl4so1r	cmpxsu9qy003phke65kkykwv8	24	C	Genel Test	2026-06-05 09:16:03.567	2026-06-05 09:16:03.567	0.2	\N
cmq0plwts00z4hk8dnubex5u4	cmpxsu9qy003phke65kkykwv8	25	B	Genel Test	2026-06-05 09:16:03.567	2026-06-05 09:16:03.567	0.2	\N
cmq0plwts00z5hk8db3ik82bj	cmpxsu9qy003phke65kkykwv8	26	C	Genel Test	2026-06-05 09:16:03.567	2026-06-05 09:16:03.567	0.2	\N
cmq0plwts00z6hk8dqaq7mw1t	cmpxsu9qy003phke65kkykwv8	27	B	Genel Test	2026-06-05 09:16:03.567	2026-06-05 09:16:03.567	0.2	\N
cmq0plwts00z7hk8dfnanqj3g	cmpxsu9qy003phke65kkykwv8	28	E	Genel Test	2026-06-05 09:16:03.567	2026-06-05 09:16:03.567	0.2	\N
cmq0plwts00z8hk8d2ghczvv8	cmpxsu9qy003phke65kkykwv8	29	B	Genel Test	2026-06-05 09:16:03.567	2026-06-05 09:16:03.567	0.2	\N
cmq0plwts00z9hk8dz1p7fb4h	cmpxsu9qy003phke65kkykwv8	30	B	Genel Test	2026-06-05 09:16:03.567	2026-06-05 09:16:03.567	0.2	\N
cmq0plwts00zahk8dd2if6ato	cmpxsu9qy003phke65kkykwv8	31	A	Genel Test	2026-06-05 09:16:03.567	2026-06-05 09:16:03.567	0.2	\N
cmq0plwts00zbhk8db5gz9rqb	cmpxsu9qy003phke65kkykwv8	32	B	Genel Test	2026-06-05 09:16:03.567	2026-06-05 09:16:03.567	0.2	\N
cmq0plwts00zchk8d7654c7i3	cmpxsu9qy003phke65kkykwv8	33	D	Genel Test	2026-06-05 09:16:03.567	2026-06-05 09:16:03.567	0.2	\N
cmq0plwtt00zdhk8d79dwoley	cmpxsu9qy003phke65kkykwv8	34	D	Genel Test	2026-06-05 09:16:03.567	2026-06-05 09:16:03.567	0.2	\N
cmq0plwtt00zehk8dwphmrbqf	cmpxsu9qy003phke65kkykwv8	35	E	Genel Test	2026-06-05 09:16:03.567	2026-06-05 09:16:03.567	0.2	\N
cmq0plwtt00zfhk8dkxj4zuaw	cmpxsu9qy003phke65kkykwv8	36	C	Genel Test	2026-06-05 09:16:03.567	2026-06-05 09:16:03.567	0.2	\N
cmq0plwtt00zghk8dx6gz6j6u	cmpxsu9qy003phke65kkykwv8	37	A	Genel Test	2026-06-05 09:16:03.567	2026-06-05 09:16:03.567	0.2	\N
cmq0plwtt00zhhk8dshqigpru	cmpxsu9qy003phke65kkykwv8	38	E	Genel Test	2026-06-05 09:16:03.567	2026-06-05 09:16:03.567	0.2	\N
cmq0plwtt00zihk8d9mhxk1yb	cmpxsu9qy003phke65kkykwv8	39	E	Genel Test	2026-06-05 09:16:03.567	2026-06-05 09:16:03.567	0.2	\N
cmq0plwtt00zjhk8dmagposs4	cmpxsu9qy003phke65kkykwv8	40	C	Genel Test	2026-06-05 09:16:03.567	2026-06-05 09:16:03.567	0.2	\N
cmq0pmbqq00zkhk8d6kl1t1md	cmpxshh83002ihke6w6k0fvdx	1	C	Genel Test	2026-06-05 09:16:22.898	2026-06-05 09:16:22.898	0.2	\N
cmq0pmbqq00zlhk8dmc8r02s9	cmpxshh83002ihke6w6k0fvdx	2	C	Genel Test	2026-06-05 09:16:22.898	2026-06-05 09:16:22.898	0.2	\N
cmq0pmbqq00zmhk8d2e5vwjyl	cmpxshh83002ihke6w6k0fvdx	3	A	Genel Test	2026-06-05 09:16:22.898	2026-06-05 09:16:22.898	0.2	\N
cmq0pmbqq00znhk8dw7f10dxe	cmpxshh83002ihke6w6k0fvdx	4	E	Genel Test	2026-06-05 09:16:22.898	2026-06-05 09:16:22.898	0.2	\N
cmq0pmbqq00zohk8d9l1ji9nd	cmpxshh83002ihke6w6k0fvdx	5	B	Genel Test	2026-06-05 09:16:22.898	2026-06-05 09:16:22.898	0.2	\N
cmq0pmbqq00zphk8dzohnpes8	cmpxshh83002ihke6w6k0fvdx	6	C	Genel Test	2026-06-05 09:16:22.898	2026-06-05 09:16:22.898	0.2	\N
cmq0pmbqq00zqhk8dqtc24avp	cmpxshh83002ihke6w6k0fvdx	7	A	Genel Test	2026-06-05 09:16:22.898	2026-06-05 09:16:22.898	0.2	\N
cmq0pmbqq00zrhk8di04t3d5k	cmpxshh83002ihke6w6k0fvdx	8	B	Genel Test	2026-06-05 09:16:22.898	2026-06-05 09:16:22.898	0.2	\N
cmq0pmbqq00zshk8d9htg7l23	cmpxshh83002ihke6w6k0fvdx	9	E	Genel Test	2026-06-05 09:16:22.898	2026-06-05 09:16:22.898	0.2	\N
cmq0pmbqr00zthk8dg6zdyyl0	cmpxshh83002ihke6w6k0fvdx	10	B	Genel Test	2026-06-05 09:16:22.898	2026-06-05 09:16:22.898	0.2	\N
cmq0pmbqr00zuhk8dknhijpt2	cmpxshh83002ihke6w6k0fvdx	11	B	Genel Test	2026-06-05 09:16:22.898	2026-06-05 09:16:22.898	0.2	\N
cmq0pmbqr00zvhk8dtolxej5x	cmpxshh83002ihke6w6k0fvdx	12	D	Genel Test	2026-06-05 09:16:22.898	2026-06-05 09:16:22.898	0.2	\N
cmq0pmbqr00zwhk8dy3aq4qdk	cmpxshh83002ihke6w6k0fvdx	13	B	Genel Test	2026-06-05 09:16:22.898	2026-06-05 09:16:22.898	0.2	\N
cmq0pmbqr00zxhk8dzuiz0fhu	cmpxshh83002ihke6w6k0fvdx	14	D	Genel Test	2026-06-05 09:16:22.898	2026-06-05 09:16:22.898	0.2	\N
cmq0pmbqr00zyhk8dtmu28dle	cmpxshh83002ihke6w6k0fvdx	15	C	Genel Test	2026-06-05 09:16:22.898	2026-06-05 09:16:22.898	0.2	\N
cmq0pmbqr00zzhk8drh794w64	cmpxshh83002ihke6w6k0fvdx	16	E	Genel Test	2026-06-05 09:16:22.898	2026-06-05 09:16:22.898	0.2	\N
cmq0pmbqr0100hk8dkbgd8tlo	cmpxshh83002ihke6w6k0fvdx	17	A	Genel Test	2026-06-05 09:16:22.898	2026-06-05 09:16:22.898	0.2	\N
cmq0pmbqr0101hk8d5cyc3bjc	cmpxshh83002ihke6w6k0fvdx	18	D	Genel Test	2026-06-05 09:16:22.898	2026-06-05 09:16:22.898	0.2	\N
cmq0pmbqr0102hk8d9bjrrge9	cmpxshh83002ihke6w6k0fvdx	19	E	Genel Test	2026-06-05 09:16:22.898	2026-06-05 09:16:22.898	0.2	\N
cmq0pmbqr0103hk8dt9jbqd6n	cmpxshh83002ihke6w6k0fvdx	20	D	Genel Test	2026-06-05 09:16:22.898	2026-06-05 09:16:22.898	0.2	\N
cmq0pmbqr0104hk8dhvzi99if	cmpxshh83002ihke6w6k0fvdx	21	B	Genel Test	2026-06-05 09:16:22.898	2026-06-05 09:16:22.898	0.2	\N
cmq0qhjfe01ighk8dwdlpdvut	cmpcemfd9003khkdzydlfo0v9	1	C	Maliye	2026-06-05 09:40:39.193	2026-06-05 09:40:39.193	0.2	\N
cmq0qhjfe01ihhk8d1w5iimyp	cmpcemfd9003khkdzydlfo0v9	2	A	Maliye	2026-06-05 09:40:39.193	2026-06-05 09:40:39.193	0.2	\N
cmq0qhjfe01iihk8dnhufvk8w	cmpcemfd9003khkdzydlfo0v9	3	B	Maliye	2026-06-05 09:40:39.193	2026-06-05 09:40:39.193	0.2	\N
cmq0qhjfe01ijhk8dv1i8dmd2	cmpcemfd9003khkdzydlfo0v9	4	C	Maliye	2026-06-05 09:40:39.193	2026-06-05 09:40:39.193	0.2	\N
cmq0qhjfe01ikhk8df3dckgun	cmpcemfd9003khkdzydlfo0v9	5	E	Maliye	2026-06-05 09:40:39.193	2026-06-05 09:40:39.193	0.2	\N
cmq0qhjfe01ilhk8dvmo32f00	cmpcemfd9003khkdzydlfo0v9	6	D	Maliye	2026-06-05 09:40:39.193	2026-06-05 09:40:39.193	0.2	\N
cmq0qhjfe01imhk8dfwjazvgs	cmpcemfd9003khkdzydlfo0v9	7	B	Maliye	2026-06-05 09:40:39.193	2026-06-05 09:40:39.193	0.2	\N
cmq0qhjfe01inhk8doavpjpor	cmpcemfd9003khkdzydlfo0v9	8	A	Maliye	2026-06-05 09:40:39.193	2026-06-05 09:40:39.193	0.2	\N
cmq0qhjfe01iohk8dz57an4pg	cmpcemfd9003khkdzydlfo0v9	9	C	Maliye	2026-06-05 09:40:39.193	2026-06-05 09:40:39.193	0.2	\N
cmq0qhjfe01iphk8dn0icm3hg	cmpcemfd9003khkdzydlfo0v9	10	B	Maliye	2026-06-05 09:40:39.193	2026-06-05 09:40:39.193	0.2	\N
cmq0qhjfe01iqhk8dbvemy7ah	cmpcemfd9003khkdzydlfo0v9	11	B	Maliye	2026-06-05 09:40:39.193	2026-06-05 09:40:39.193	0.2	\N
cmq0qhjfe01irhk8d87x09414	cmpcemfd9003khkdzydlfo0v9	12	D	Maliye	2026-06-05 09:40:39.193	2026-06-05 09:40:39.193	0.2	\N
cmq0qhjfe01ishk8dfn6r4xz5	cmpcemfd9003khkdzydlfo0v9	13	A	Maliye	2026-06-05 09:40:39.193	2026-06-05 09:40:39.193	0.2	\N
cmq0qhjfe01ithk8dfyj8c1hm	cmpcemfd9003khkdzydlfo0v9	14	E	Maliye	2026-06-05 09:40:39.193	2026-06-05 09:40:39.193	0.2	\N
cmq0qhjfe01iuhk8diyi4xevv	cmpcemfd9003khkdzydlfo0v9	15	D	Maliye	2026-06-05 09:40:39.193	2026-06-05 09:40:39.193	0.2	\N
cmq0qhjfe01ivhk8d356zqb8c	cmpcemfd9003khkdzydlfo0v9	16	B	Maliye	2026-06-05 09:40:39.193	2026-06-05 09:40:39.193	0.2	\N
cmq0qhjfe01iwhk8dmzhlcnnq	cmpcemfd9003khkdzydlfo0v9	17	C	Maliye	2026-06-05 09:40:39.193	2026-06-05 09:40:39.193	0.2	\N
cmq0qhjfe01ixhk8drthf35uu	cmpcemfd9003khkdzydlfo0v9	18	A	Maliye	2026-06-05 09:40:39.193	2026-06-05 09:40:39.193	0.2	\N
cmq0qhjfe01iyhk8dldkkn1sy	cmpcemfd9003khkdzydlfo0v9	19	E	Maliye	2026-06-05 09:40:39.193	2026-06-05 09:40:39.193	0.2	\N
cmq0qhjfe01izhk8dc6ytx2n5	cmpcemfd9003khkdzydlfo0v9	20	D	Maliye	2026-06-05 09:40:39.193	2026-06-05 09:40:39.193	0.2	\N
cmq0qhjfe01j0hk8dynx6kcvm	cmpcemfd9003khkdzydlfo0v9	21	C	Maliye	2026-06-05 09:40:39.193	2026-06-05 09:40:39.193	0.2	\N
cmq0qhjfe01j1hk8dwd2j0qce	cmpcemfd9003khkdzydlfo0v9	22	A	Maliye	2026-06-05 09:40:39.193	2026-06-05 09:40:39.193	0.2	\N
cmq0qhjfe01j2hk8d88f5j6n5	cmpcemfd9003khkdzydlfo0v9	23	A	Maliye	2026-06-05 09:40:39.193	2026-06-05 09:40:39.193	0.2	\N
cmq0pmbqr0105hk8djym2jecy	cmpxshh83002ihke6w6k0fvdx	22	E	Genel Test	2026-06-05 09:16:22.898	2026-06-05 09:16:22.898	0.2	\N
cmq0pmbqr0106hk8d67h2flh4	cmpxshh83002ihke6w6k0fvdx	23	D	Genel Test	2026-06-05 09:16:22.898	2026-06-05 09:16:22.898	0.2	\N
cmq0pmbqr0107hk8du8989f6v	cmpxshh83002ihke6w6k0fvdx	24	B	Genel Test	2026-06-05 09:16:22.898	2026-06-05 09:16:22.898	0.2	\N
cmq0pmbqr0108hk8dickoly22	cmpxshh83002ihke6w6k0fvdx	25	C	Genel Test	2026-06-05 09:16:22.898	2026-06-05 09:16:22.898	0.2	\N
cmq0pmbqr0109hk8domwpx870	cmpxshh83002ihke6w6k0fvdx	26	B	Genel Test	2026-06-05 09:16:22.898	2026-06-05 09:16:22.898	0.2	\N
cmq0pmbqr010ahk8dsfhm8okb	cmpxshh83002ihke6w6k0fvdx	27	E	Genel Test	2026-06-05 09:16:22.898	2026-06-05 09:16:22.898	0.2	\N
cmq0pmbqr010bhk8dz4axp05a	cmpxshh83002ihke6w6k0fvdx	28	C	Genel Test	2026-06-05 09:16:22.898	2026-06-05 09:16:22.898	0.2	\N
cmq0pmbqr010chk8def4djul0	cmpxshh83002ihke6w6k0fvdx	29	D	Genel Test	2026-06-05 09:16:22.898	2026-06-05 09:16:22.898	0.2	\N
cmq0pmbqr010dhk8dseswjbw4	cmpxshh83002ihke6w6k0fvdx	30	B	Genel Test	2026-06-05 09:16:22.898	2026-06-05 09:16:22.898	0.2	\N
cmq0pmbqr010ehk8duhjk9kqy	cmpxshh83002ihke6w6k0fvdx	31	E	Genel Test	2026-06-05 09:16:22.898	2026-06-05 09:16:22.898	0.2	\N
cmq0pmbqr010fhk8drtgymfhc	cmpxshh83002ihke6w6k0fvdx	32	A	Genel Test	2026-06-05 09:16:22.898	2026-06-05 09:16:22.898	0.2	\N
cmq0pmbqr010ghk8dw2revuef	cmpxshh83002ihke6w6k0fvdx	33	E	Genel Test	2026-06-05 09:16:22.898	2026-06-05 09:16:22.898	0.2	\N
cmq0pmbqr010hhk8ddayft3x4	cmpxshh83002ihke6w6k0fvdx	34	C	Genel Test	2026-06-05 09:16:22.898	2026-06-05 09:16:22.898	0.2	\N
cmq0pmbqr010ihk8dabibv1q2	cmpxshh83002ihke6w6k0fvdx	35	E	Genel Test	2026-06-05 09:16:22.898	2026-06-05 09:16:22.898	0.2	\N
cmq0pmbqr010jhk8dpopxtl6e	cmpxshh83002ihke6w6k0fvdx	36	D	Genel Test	2026-06-05 09:16:22.898	2026-06-05 09:16:22.898	0.2	\N
cmq0pmbqr010khk8d1fsryh4z	cmpxshh83002ihke6w6k0fvdx	37	A	Genel Test	2026-06-05 09:16:22.898	2026-06-05 09:16:22.898	0.2	\N
cmq0pmbqs010lhk8d4xmimji0	cmpxshh83002ihke6w6k0fvdx	38	C	Genel Test	2026-06-05 09:16:22.898	2026-06-05 09:16:22.898	0.2	\N
cmq0pmbqs010mhk8dphzaeia5	cmpxshh83002ihke6w6k0fvdx	39	C	Genel Test	2026-06-05 09:16:22.898	2026-06-05 09:16:22.898	0.2	\N
cmq0pmbqs010nhk8dd8blwy7a	cmpxshh83002ihke6w6k0fvdx	40	A	Genel Test	2026-06-05 09:16:22.898	2026-06-05 09:16:22.898	0.2	\N
cmq0pmsmj010ohk8djyed2xbe	cmpxrepeb0004hke67fbajpe7	1	A	Genel Test	2026-06-05 09:16:44.779	2026-06-05 09:16:44.779	0.2	\N
cmq0pmsmj010phk8d7277lmid	cmpxrepeb0004hke67fbajpe7	2	C	Genel Test	2026-06-05 09:16:44.779	2026-06-05 09:16:44.779	0.2	\N
cmq0pmsmj010qhk8dm3kqp2yj	cmpxrepeb0004hke67fbajpe7	3	C	Genel Test	2026-06-05 09:16:44.779	2026-06-05 09:16:44.779	0.2	\N
cmq0pmsmj010rhk8dvupw3vvo	cmpxrepeb0004hke67fbajpe7	4	A	Genel Test	2026-06-05 09:16:44.779	2026-06-05 09:16:44.779	0.2	\N
cmq0pmsmj010shk8dc3opo5of	cmpxrepeb0004hke67fbajpe7	5	C	Genel Test	2026-06-05 09:16:44.779	2026-06-05 09:16:44.779	0.2	\N
cmq0pmsmj010thk8dkgakshgp	cmpxrepeb0004hke67fbajpe7	6	E	Genel Test	2026-06-05 09:16:44.779	2026-06-05 09:16:44.779	0.2	\N
cmq0pmsmj010uhk8dyk8t0nu8	cmpxrepeb0004hke67fbajpe7	7	D	Genel Test	2026-06-05 09:16:44.779	2026-06-05 09:16:44.779	0.2	\N
cmq0pmsmj010vhk8dylw8i3rr	cmpxrepeb0004hke67fbajpe7	8	C	Genel Test	2026-06-05 09:16:44.779	2026-06-05 09:16:44.779	0.2	\N
cmq0pmsmj010whk8do9zoc4q5	cmpxrepeb0004hke67fbajpe7	9	E	Genel Test	2026-06-05 09:16:44.779	2026-06-05 09:16:44.779	0.2	\N
cmq0pmsmj010xhk8dhknxp4iv	cmpxrepeb0004hke67fbajpe7	10	E	Genel Test	2026-06-05 09:16:44.779	2026-06-05 09:16:44.779	0.2	\N
cmq0pmsmj010yhk8d32m0x565	cmpxrepeb0004hke67fbajpe7	11	C	Genel Test	2026-06-05 09:16:44.779	2026-06-05 09:16:44.779	0.2	\N
cmq0pmsmj010zhk8d4ue6xb9a	cmpxrepeb0004hke67fbajpe7	12	D	Genel Test	2026-06-05 09:16:44.779	2026-06-05 09:16:44.779	0.2	\N
cmq0pmsmj0110hk8dcx9uo6yq	cmpxrepeb0004hke67fbajpe7	13	E	Genel Test	2026-06-05 09:16:44.779	2026-06-05 09:16:44.779	0.2	\N
cmq0pmsmj0111hk8d99yi3g3t	cmpxrepeb0004hke67fbajpe7	14	A	Genel Test	2026-06-05 09:16:44.779	2026-06-05 09:16:44.779	0.2	\N
cmq0pmsmj0112hk8dhwhphb9e	cmpxrepeb0004hke67fbajpe7	15	B	Genel Test	2026-06-05 09:16:44.779	2026-06-05 09:16:44.779	0.2	\N
cmq0pmsmj0113hk8dc8jzbsdd	cmpxrepeb0004hke67fbajpe7	16	D	Genel Test	2026-06-05 09:16:44.779	2026-06-05 09:16:44.779	0.2	\N
cmq0pmsmj0114hk8dvaa0lp16	cmpxrepeb0004hke67fbajpe7	17	A	Genel Test	2026-06-05 09:16:44.779	2026-06-05 09:16:44.779	0.2	\N
cmq0pmsmj0115hk8ds9xen5vt	cmpxrepeb0004hke67fbajpe7	18	D	Genel Test	2026-06-05 09:16:44.779	2026-06-05 09:16:44.779	0.2	\N
cmq0pmsmj0116hk8dunwqjk4l	cmpxrepeb0004hke67fbajpe7	19	A	Genel Test	2026-06-05 09:16:44.779	2026-06-05 09:16:44.779	0.2	\N
cmq0pmsmj0117hk8d244h6e1f	cmpxrepeb0004hke67fbajpe7	20	C	Genel Test	2026-06-05 09:16:44.779	2026-06-05 09:16:44.779	0.2	\N
cmq0pmsmj0118hk8dor7bchrv	cmpxrepeb0004hke67fbajpe7	21	D	Genel Test	2026-06-05 09:16:44.779	2026-06-05 09:16:44.779	0.2	\N
cmq0qhjfe01j3hk8dl7zis9y6	cmpcemfd9003khkdzydlfo0v9	24	D	Maliye	2026-06-05 09:40:39.193	2026-06-05 09:40:39.193	0.2	\N
cmq0qhjfe01j4hk8daxze2rm2	cmpcemfd9003khkdzydlfo0v9	25	B	Maliye	2026-06-05 09:40:39.193	2026-06-05 09:40:39.193	0.2	\N
cmq0qhjfe01j5hk8dw8hbfjav	cmpcemfd9003khkdzydlfo0v9	26	E	Maliye	2026-06-05 09:40:39.193	2026-06-05 09:40:39.193	0.2	\N
cmq0qhjfe01j6hk8ddg0i6oak	cmpcemfd9003khkdzydlfo0v9	27	A	Maliye	2026-06-05 09:40:39.193	2026-06-05 09:40:39.193	0.2	\N
cmq0qhjfe01j7hk8dxcnll4zf	cmpcemfd9003khkdzydlfo0v9	28	D	Maliye	2026-06-05 09:40:39.193	2026-06-05 09:40:39.193	0.2	\N
cmq0qhjfe01j8hk8ds2calyjs	cmpcemfd9003khkdzydlfo0v9	29	A	Maliye	2026-06-05 09:40:39.193	2026-06-05 09:40:39.193	0.2	\N
cmq0qhjfe01j9hk8dpngmaqbk	cmpcemfd9003khkdzydlfo0v9	30	E	Maliye	2026-06-05 09:40:39.193	2026-06-05 09:40:39.193	0.2	\N
cmq0qhjff01jahk8d3riiskxc	cmpcemfd9003khkdzydlfo0v9	31	C	Maliye	2026-06-05 09:40:39.193	2026-06-05 09:40:39.193	0.2	\N
cmq0qhjff01jbhk8d3c4ghle2	cmpcemfd9003khkdzydlfo0v9	32	C	Maliye	2026-06-05 09:40:39.193	2026-06-05 09:40:39.193	0.2	\N
cmq0qhjff01jchk8d8e00t1o2	cmpcemfd9003khkdzydlfo0v9	33	E	Maliye	2026-06-05 09:40:39.193	2026-06-05 09:40:39.193	0.2	\N
cmq0qhjff01jdhk8dkpq1gn7l	cmpcemfd9003khkdzydlfo0v9	34	C	Maliye	2026-06-05 09:40:39.193	2026-06-05 09:40:39.193	0.2	\N
cmq0qhjff01jehk8djvykqsxg	cmpcemfd9003khkdzydlfo0v9	35	A	Maliye	2026-06-05 09:40:39.193	2026-06-05 09:40:39.193	0.2	\N
cmq0qhjff01jfhk8dx5j4hgtg	cmpcemfd9003khkdzydlfo0v9	36	E	Maliye	2026-06-05 09:40:39.193	2026-06-05 09:40:39.193	0.2	\N
cmq0qhjff01jghk8dpl1nzjmu	cmpcemfd9003khkdzydlfo0v9	37	D	Maliye	2026-06-05 09:40:39.193	2026-06-05 09:40:39.193	0.2	\N
cmq0qhjff01jhhk8d929necfn	cmpcemfd9003khkdzydlfo0v9	38	E	Maliye	2026-06-05 09:40:39.193	2026-06-05 09:40:39.193	0.2	\N
cmq0qhjff01jihk8drlwvxfrx	cmpcemfd9003khkdzydlfo0v9	39	D	Maliye	2026-06-05 09:40:39.193	2026-06-05 09:40:39.193	0.2	\N
cmq0qhjff01jjhk8d423wq7j2	cmpcemfd9003khkdzydlfo0v9	40	E	Maliye	2026-06-05 09:40:39.193	2026-06-05 09:40:39.193	0.2	\N
cmq0pmsmk0119hk8de53wz0k4	cmpxrepeb0004hke67fbajpe7	22	E	Genel Test	2026-06-05 09:16:44.779	2026-06-05 09:16:44.779	0.2	\N
cmq0pmsmk011ahk8do45q50pg	cmpxrepeb0004hke67fbajpe7	23	A	Genel Test	2026-06-05 09:16:44.779	2026-06-05 09:16:44.779	0.2	\N
cmq0pmsmk011bhk8dah7dwtxz	cmpxrepeb0004hke67fbajpe7	24	E	Genel Test	2026-06-05 09:16:44.779	2026-06-05 09:16:44.779	0.2	\N
cmq0pmsmk011chk8dzaydw58f	cmpxrepeb0004hke67fbajpe7	25	D	Genel Test	2026-06-05 09:16:44.779	2026-06-05 09:16:44.779	0.2	\N
cmq0pmsmk011dhk8ds2bcx2a1	cmpxrepeb0004hke67fbajpe7	26	D	Genel Test	2026-06-05 09:16:44.779	2026-06-05 09:16:44.779	0.2	\N
cmq0pmsmk011ehk8dud7ulfpc	cmpxrepeb0004hke67fbajpe7	27	B	Genel Test	2026-06-05 09:16:44.779	2026-06-05 09:16:44.779	0.2	\N
cmq0pmsmk011fhk8dmqtbnpzt	cmpxrepeb0004hke67fbajpe7	28	C	Genel Test	2026-06-05 09:16:44.779	2026-06-05 09:16:44.779	0.2	\N
cmq0pmsmk011ghk8d2rnd8n7r	cmpxrepeb0004hke67fbajpe7	29	C	Genel Test	2026-06-05 09:16:44.779	2026-06-05 09:16:44.779	0.2	\N
cmq0pmsmk011hhk8dekyavm2j	cmpxrepeb0004hke67fbajpe7	30	B	Genel Test	2026-06-05 09:16:44.779	2026-06-05 09:16:44.779	0.2	\N
cmq0pmsmk011ihk8d7etekxpv	cmpxrepeb0004hke67fbajpe7	31	D	Genel Test	2026-06-05 09:16:44.779	2026-06-05 09:16:44.779	0.2	\N
cmq0pmsmk011jhk8dty1g2kvt	cmpxrepeb0004hke67fbajpe7	32	A	Genel Test	2026-06-05 09:16:44.779	2026-06-05 09:16:44.779	0.2	\N
cmq0pmsmk011khk8dug53gqx0	cmpxrepeb0004hke67fbajpe7	33	C	Genel Test	2026-06-05 09:16:44.779	2026-06-05 09:16:44.779	0.2	\N
cmq0pmsmk011lhk8dj5knf3xg	cmpxrepeb0004hke67fbajpe7	34	C	Genel Test	2026-06-05 09:16:44.779	2026-06-05 09:16:44.779	0.2	\N
cmq0pmsmk011mhk8d2fcs961z	cmpxrepeb0004hke67fbajpe7	35	B	Genel Test	2026-06-05 09:16:44.779	2026-06-05 09:16:44.779	0.2	\N
cmq0pmsmk011nhk8d6i47mju1	cmpxrepeb0004hke67fbajpe7	36	D	Genel Test	2026-06-05 09:16:44.779	2026-06-05 09:16:44.779	0.2	\N
cmq0pmsmk011ohk8dm2qomki6	cmpxrepeb0004hke67fbajpe7	37	A	Genel Test	2026-06-05 09:16:44.779	2026-06-05 09:16:44.779	0.2	\N
cmq0pmsmk011phk8d7xzzuesf	cmpxrepeb0004hke67fbajpe7	38	C	Genel Test	2026-06-05 09:16:44.779	2026-06-05 09:16:44.779	0.2	\N
cmq0pmsmk011qhk8dkj0d8863	cmpxrepeb0004hke67fbajpe7	39	E	Genel Test	2026-06-05 09:16:44.779	2026-06-05 09:16:44.779	0.2	\N
cmq0pmsmk011rhk8dwbjndqq6	cmpxrepeb0004hke67fbajpe7	40	C	Genel Test	2026-06-05 09:16:44.779	2026-06-05 09:16:44.779	0.2	\N
cmpzm0im000v4hk8ce7h8xstf	cmpcmu9th010mhkdzuyws3446	1	A	Genel Test	2026-06-04 14:47:40.344	2026-06-04 14:47:40.344	0.2	\N
cmpzm0im000v5hk8ch42azrn8	cmpcmu9th010mhkdzuyws3446	2	A	Genel Test	2026-06-04 14:47:40.344	2026-06-04 14:47:40.344	0.2	\N
cmpzm0im000v6hk8ceihv719f	cmpcmu9th010mhkdzuyws3446	3	B	Genel Test	2026-06-04 14:47:40.344	2026-06-04 14:47:40.344	0.2	\N
cmpzm0im000v7hk8cdzynahnf	cmpcmu9th010mhkdzuyws3446	4	D	Genel Test	2026-06-04 14:47:40.344	2026-06-04 14:47:40.344	0.2	\N
cmpzm0im000v8hk8csltqhy1k	cmpcmu9th010mhkdzuyws3446	5	D	Genel Test	2026-06-04 14:47:40.344	2026-06-04 14:47:40.344	0.2	\N
cmpzm0im000v9hk8cq7cpllvi	cmpcmu9th010mhkdzuyws3446	6	D	Genel Test	2026-06-04 14:47:40.344	2026-06-04 14:47:40.344	0.2	\N
cmpzm0im000vahk8cv4gy9chd	cmpcmu9th010mhkdzuyws3446	7	C	Genel Test	2026-06-04 14:47:40.344	2026-06-04 14:47:40.344	0.2	\N
cmpzm0im000vbhk8cj3bkztfq	cmpcmu9th010mhkdzuyws3446	8	C	Genel Test	2026-06-04 14:47:40.344	2026-06-04 14:47:40.344	0.2	\N
cmpzm0im000vchk8cx7g5zl7r	cmpcmu9th010mhkdzuyws3446	9	C	Genel Test	2026-06-04 14:47:40.344	2026-06-04 14:47:40.344	0.2	\N
cmpzm0im000vdhk8c0dqhid0a	cmpcmu9th010mhkdzuyws3446	10	A	Genel Test	2026-06-04 14:47:40.344	2026-06-04 14:47:40.344	0.2	\N
cmpzm0im000vehk8cb8d2nru6	cmpcmu9th010mhkdzuyws3446	11	E	Genel Test	2026-06-04 14:47:40.344	2026-06-04 14:47:40.344	0.2	\N
cmpzk9m0800a0hk8c7ha8c3cl	cmpgmklqk0002hk9karfvcygv	1	C	Genel Yetenek	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0800a1hk8c5c9yyhnw	cmpgmklqk0002hk9karfvcygv	2	E	Genel Yetenek	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0800a2hk8cdftq4uxe	cmpgmklqk0002hk9karfvcygv	3	D	Genel Yetenek	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0900a3hk8cqfe3i5w0	cmpgmklqk0002hk9karfvcygv	4	E	Genel Yetenek	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0900a4hk8cspr9e8eh	cmpgmklqk0002hk9karfvcygv	5	D	Genel Yetenek	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0900a5hk8cwzhpo0jo	cmpgmklqk0002hk9karfvcygv	6	E	Genel Yetenek	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0900a6hk8cv0zh283q	cmpgmklqk0002hk9karfvcygv	7	B	Genel Yetenek	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0900a7hk8c4wc760u5	cmpgmklqk0002hk9karfvcygv	8	B	Genel Yetenek	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0900a8hk8cblwhj04q	cmpgmklqk0002hk9karfvcygv	9	E	Genel Yetenek	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0900a9hk8c7jb2bkh4	cmpgmklqk0002hk9karfvcygv	10	A	Genel Yetenek	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0900aahk8crzwxlsx9	cmpgmklqk0002hk9karfvcygv	11	C	Genel Yetenek	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0900abhk8cmc06776i	cmpgmklqk0002hk9karfvcygv	12	C	Genel Yetenek	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0900achk8cc2j9tdu6	cmpgmklqk0002hk9karfvcygv	13	A	Genel Yetenek	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0900adhk8c7wyk4dbm	cmpgmklqk0002hk9karfvcygv	14	E	Genel Yetenek	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0900aehk8cou5t6ujd	cmpgmklqk0002hk9karfvcygv	15	C	Genel Yetenek	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0900afhk8cemmyiqze	cmpgmklqk0002hk9karfvcygv	16	B	Genel Yetenek	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0900aghk8cuv1r9i44	cmpgmklqk0002hk9karfvcygv	17	D	Genel Yetenek	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0900ahhk8cblwb9zuv	cmpgmklqk0002hk9karfvcygv	18	B	Genel Yetenek	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0900aihk8cvn3uigwk	cmpgmklqk0002hk9karfvcygv	19	D	Genel Yetenek	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0900ajhk8cfvnt8c4w	cmpgmklqk0002hk9karfvcygv	20	C	Genel Yetenek	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0900akhk8c7mumgp4u	cmpgmklqk0002hk9karfvcygv	21	D	Genel Yetenek	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0900alhk8c9ak7wtx1	cmpgmklqk0002hk9karfvcygv	22	A	Genel Yetenek	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0900amhk8ct54pp7gi	cmpgmklqk0002hk9karfvcygv	23	B	Genel Yetenek	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0900anhk8cfsbeksli	cmpgmklqk0002hk9karfvcygv	24	B	Genel Yetenek	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0900aohk8cctqezt30	cmpgmklqk0002hk9karfvcygv	25	B	Genel Yetenek	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0900aphk8ciqzdopk7	cmpgmklqk0002hk9karfvcygv	26	C	Genel Yetenek	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0900aqhk8cbyd3ukru	cmpgmklqk0002hk9karfvcygv	27	C	Genel Yetenek	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0900arhk8cqrsgas5w	cmpgmklqk0002hk9karfvcygv	28	D	Genel Yetenek	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0900ashk8cag5ydxr8	cmpgmklqk0002hk9karfvcygv	29	A	Genel Yetenek	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0900athk8chit1n9b3	cmpgmklqk0002hk9karfvcygv	30	A	Genel Yetenek	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0900auhk8c1ut0leds	cmpgmklqk0002hk9karfvcygv	31	C	Genel Yetenek	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0900avhk8c5lwd7sta	cmpgmklqk0002hk9karfvcygv	32	A	Genel Yetenek	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0900awhk8cfnyt5h19	cmpgmklqk0002hk9karfvcygv	33	A	Genel Yetenek	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0900axhk8czf6av13s	cmpgmklqk0002hk9karfvcygv	34	B	Genel Yetenek	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0900ayhk8c6oofprff	cmpgmklqk0002hk9karfvcygv	35	C	Genel Yetenek	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0a00azhk8cpgx797bx	cmpgmklqk0002hk9karfvcygv	36	B	Genel Yetenek	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0a00b0hk8cuvz6lked	cmpgmklqk0002hk9karfvcygv	37	C	Genel Yetenek	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0a00b1hk8cbejfzqxa	cmpgmklqk0002hk9karfvcygv	38	C	Genel Yetenek	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0a00b2hk8ccbqlfijr	cmpgmklqk0002hk9karfvcygv	39	B	Genel Yetenek	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzk9m0a00b3hk8chighq2vu	cmpgmklqk0002hk9karfvcygv	40	B	Genel Yetenek	2026-06-04 13:58:45.416	2026-06-04 13:58:45.416	0.1	\N
cmpzkdjo400gghk8cvms2u9ty	cmpwswxce0002hkwpttlr7zwx	113	B	Genel Kültür	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo400ghhk8csvfevaia	cmpwswxce0002hkwpttlr7zwx	114	B	Genel Kültür	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo400gihk8cffhn4n2j	cmpwswxce0002hkwpttlr7zwx	115	A	Genel Kültür	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo400gjhk8cc4wn645s	cmpwswxce0002hkwpttlr7zwx	116	A	Genel Kültür	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo400gkhk8cprnxoo7m	cmpwswxce0002hkwpttlr7zwx	117	A	Genel Kültür	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo400glhk8c9ptokmo8	cmpwswxce0002hkwpttlr7zwx	118	C	Genel Kültür	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo400gmhk8c6rmmlqm3	cmpwswxce0002hkwpttlr7zwx	119	B	Genel Kültür	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzkdjo400gnhk8cxtzmz594	cmpwswxce0002hkwpttlr7zwx	120	A	Genel Kültür	2026-06-04 14:01:49.008	2026-06-04 14:01:49.008	0.1	\N
cmpzm0im000vfhk8crmg5ijyb	cmpcmu9th010mhkdzuyws3446	12	C	Genel Test	2026-06-04 14:47:40.344	2026-06-04 14:47:40.344	0.2	\N
cmpzm0im000vghk8cllhgdzer	cmpcmu9th010mhkdzuyws3446	13	D	Genel Test	2026-06-04 14:47:40.344	2026-06-04 14:47:40.344	0.2	\N
cmpzm0im000vhhk8c1gmfw22p	cmpcmu9th010mhkdzuyws3446	14	E	Genel Test	2026-06-04 14:47:40.344	2026-06-04 14:47:40.344	0.2	\N
cmpzm0im000vihk8coo1newx8	cmpcmu9th010mhkdzuyws3446	15	E	Genel Test	2026-06-04 14:47:40.344	2026-06-04 14:47:40.344	0.2	\N
cmpzm0im000vjhk8csxl5yrjr	cmpcmu9th010mhkdzuyws3446	16	A	Genel Test	2026-06-04 14:47:40.344	2026-06-04 14:47:40.344	0.2	\N
cmpzm0im000vkhk8c6erlqu1w	cmpcmu9th010mhkdzuyws3446	17	E	Genel Test	2026-06-04 14:47:40.344	2026-06-04 14:47:40.344	0.2	\N
cmpzm0im000vlhk8c6hvw5jsy	cmpcmu9th010mhkdzuyws3446	18	C	Genel Test	2026-06-04 14:47:40.344	2026-06-04 14:47:40.344	0.2	\N
cmpzm0im000vmhk8cegluj6op	cmpcmu9th010mhkdzuyws3446	19	A	Genel Test	2026-06-04 14:47:40.344	2026-06-04 14:47:40.344	0.2	\N
cmpzm0im000vnhk8c969gytye	cmpcmu9th010mhkdzuyws3446	20	D	Genel Test	2026-06-04 14:47:40.344	2026-06-04 14:47:40.344	0.2	\N
cmpzm0im000vohk8c5w0gt5a0	cmpcmu9th010mhkdzuyws3446	21	E	Genel Test	2026-06-04 14:47:40.344	2026-06-04 14:47:40.344	0.2	\N
cmpzm0im100vphk8ccm404fxt	cmpcmu9th010mhkdzuyws3446	22	D	Genel Test	2026-06-04 14:47:40.344	2026-06-04 14:47:40.344	0.2	\N
cmpzm0im100vqhk8cnnjrazbv	cmpcmu9th010mhkdzuyws3446	23	D	Genel Test	2026-06-04 14:47:40.344	2026-06-04 14:47:40.344	0.2	\N
cmpzm0im100vrhk8cuk2j779t	cmpcmu9th010mhkdzuyws3446	24	C	Genel Test	2026-06-04 14:47:40.344	2026-06-04 14:47:40.344	0.2	\N
cmpzm0im100vshk8cpi6grukm	cmpcmu9th010mhkdzuyws3446	25	B	Genel Test	2026-06-04 14:47:40.344	2026-06-04 14:47:40.344	0.2	\N
cmpzm0im100vthk8cgpu1l40t	cmpcmu9th010mhkdzuyws3446	26	D	Genel Test	2026-06-04 14:47:40.344	2026-06-04 14:47:40.344	0.2	\N
cmpzm0im100vuhk8cq2skgqoe	cmpcmu9th010mhkdzuyws3446	27	B	Genel Test	2026-06-04 14:47:40.344	2026-06-04 14:47:40.344	0.2	\N
cmpzm0im100vvhk8c2yo7e3df	cmpcmu9th010mhkdzuyws3446	28	E	Genel Test	2026-06-04 14:47:40.344	2026-06-04 14:47:40.344	0.2	\N
cmpzm0im100vwhk8cs4gkiy4l	cmpcmu9th010mhkdzuyws3446	29	C	Genel Test	2026-06-04 14:47:40.344	2026-06-04 14:47:40.344	0.2	\N
cmpzm0im100vxhk8cg74bodya	cmpcmu9th010mhkdzuyws3446	30	B	Genel Test	2026-06-04 14:47:40.344	2026-06-04 14:47:40.344	0.2	\N
cmpzm0im100vyhk8cmi05spd4	cmpcmu9th010mhkdzuyws3446	31	A	Genel Test	2026-06-04 14:47:40.344	2026-06-04 14:47:40.344	0.2	\N
cmpzm0im100vzhk8cogauyn83	cmpcmu9th010mhkdzuyws3446	32	E	Genel Test	2026-06-04 14:47:40.344	2026-06-04 14:47:40.344	0.2	\N
cmpzm0im100w0hk8ctbsr6xds	cmpcmu9th010mhkdzuyws3446	33	D	Genel Test	2026-06-04 14:47:40.344	2026-06-04 14:47:40.344	0.2	\N
cmpzm0im100w1hk8cupod2ljl	cmpcmu9th010mhkdzuyws3446	34	E	Genel Test	2026-06-04 14:47:40.344	2026-06-04 14:47:40.344	0.2	\N
cmpzm0im100w2hk8cofjtld5g	cmpcmu9th010mhkdzuyws3446	35	C	Genel Test	2026-06-04 14:47:40.344	2026-06-04 14:47:40.344	0.2	\N
cmpzm0im100w3hk8csnva06vn	cmpcmu9th010mhkdzuyws3446	36	C	Genel Test	2026-06-04 14:47:40.344	2026-06-04 14:47:40.344	0.2	\N
cmpzm0im100w4hk8c4h4nr0tx	cmpcmu9th010mhkdzuyws3446	37	D	Genel Test	2026-06-04 14:47:40.344	2026-06-04 14:47:40.344	0.2	\N
cmpzm0im100w5hk8cvlr1u0g4	cmpcmu9th010mhkdzuyws3446	38	E	Genel Test	2026-06-04 14:47:40.344	2026-06-04 14:47:40.344	0.2	\N
cmpzm0im100w6hk8c13moxt5l	cmpcmu9th010mhkdzuyws3446	39	C	Genel Test	2026-06-04 14:47:40.344	2026-06-04 14:47:40.344	0.2	\N
cmpzm0im100w7hk8cduyofbh2	cmpcmu9th010mhkdzuyws3446	40	C	Genel Test	2026-06-04 14:47:40.344	2026-06-04 14:47:40.344	0.2	\N
cmq0pgght00ighk8d32nqgvj0	cmpxw4fdb00ldhke6mjnc94ez	105	C	Genel Kültür	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgght00ihhk8dnhl7d78i	cmpxw4fdb00ldhke6mjnc94ez	106	E	Genel Kültür	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgght00iihk8dqguoq1zl	cmpxw4fdb00ldhke6mjnc94ez	107	B	Genel Kültür	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgght00ijhk8dte949f5g	cmpxw4fdb00ldhke6mjnc94ez	108	C	Genel Kültür	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgght00ikhk8d8vl9lpgd	cmpxw4fdb00ldhke6mjnc94ez	109	C	Genel Kültür	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgght00ilhk8d98wf123f	cmpxw4fdb00ldhke6mjnc94ez	110	D	Genel Kültür	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgght00imhk8dv42uy4aw	cmpxw4fdb00ldhke6mjnc94ez	111	D	Genel Kültür	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgght00inhk8dxctz82ei	cmpxw4fdb00ldhke6mjnc94ez	112	B	Genel Kültür	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgght00iohk8dxb9zcy7a	cmpxw4fdb00ldhke6mjnc94ez	113	B	Genel Kültür	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgght00iphk8dq3p68g91	cmpxw4fdb00ldhke6mjnc94ez	114	E	Genel Kültür	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgght00iqhk8dpl66xg3i	cmpxw4fdb00ldhke6mjnc94ez	115	C	Genel Kültür	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgght00irhk8d898a5a4x	cmpxw4fdb00ldhke6mjnc94ez	116	A	Genel Kültür	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgght00ishk8dcuf74rti	cmpxw4fdb00ldhke6mjnc94ez	117	B	Genel Kültür	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgght00ithk8diqz0kkaj	cmpxw4fdb00ldhke6mjnc94ez	118	B	Genel Kültür	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgght00iuhk8djlcjy0j4	cmpxw4fdb00ldhke6mjnc94ez	119	C	Genel Kültür	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
cmq0pgghu00ivhk8drpfancqt	cmpxw4fdb00ldhke6mjnc94ez	120	A	Genel Kültür	2026-06-05 09:11:49.117	2026-06-05 09:11:49.117	0.1	\N
\.


--
-- Data for Name: SecurityLog; Type: TABLE DATA; Schema: public; Owner: sinavsistemi_admin
--

COPY public."SecurityLog" (id, "examId", "userId", "actionType", details, "createdAt") FROM stdin;
\.


--
-- Data for Name: StudentAnswer; Type: TABLE DATA; Schema: public; Owner: sinavsistemi_admin
--

COPY public."StudentAnswer" (id, "resultId", "questionNumber", "selectedOption", "createdAt", "updatedAt") FROM stdin;
cmpfcr4o500xlhkzbfnibix9h	cmpfcqws200xjhkzbxd72s023	1	C	2026-05-21 10:33:02.309	2026-05-21 10:33:02.309
cmpfcr4o500xnhkzblgyoacmz	cmpfcqws200xjhkzbxd72s023	2	B	2026-05-21 10:33:02.309	2026-05-21 10:33:02.309
cmpfcr4o500xphkzbuw97zceo	cmpfcqws200xjhkzbxd72s023	3	D	2026-05-21 10:33:02.309	2026-05-21 10:33:02.309
cmpfcr4o600xrhkzbjfsif116	cmpfcqws200xjhkzbxd72s023	4	C	2026-05-21 10:33:02.309	2026-05-21 10:33:02.309
cmp8ax3j900njhk5d17uahnwr	cmp8awh6l00mdhk5duk0hpxup	20	A	2026-05-16 12:07:18.309	2026-05-16 12:07:42.163
cmpfcr4o600xthkzb6iqb5ufy	cmpfcqws200xjhkzbxd72s023	5	A	2026-05-21 10:33:02.309	2026-05-21 10:33:02.309
cmpfcr4o600xvhkzb8ifz4459	cmpfcqws200xjhkzbxd72s023	6	B	2026-05-21 10:33:02.309	2026-05-21 10:33:02.309
cmpfcr4o600xxhkzb5iglxqz6	cmpfcqws200xjhkzbxd72s023	7	B	2026-05-21 10:33:02.309	2026-05-21 10:33:02.309
cmpfcr4o700xzhkzbx10inglo	cmpfcqws200xjhkzbxd72s023	8	D	2026-05-21 10:33:02.309	2026-05-21 10:33:02.309
cmpfcr4o700y1hkzb31pu436u	cmpfcqws200xjhkzbxd72s023	9	C	2026-05-21 10:33:02.309	2026-05-21 10:33:02.309
cmpfcrcda00y3hkzbszgqq5i1	cmpfcqws200xjhkzbxd72s023	11	A	2026-05-21 10:33:12.287	2026-05-21 10:33:12.287
cmpfcrcdb00y5hkzbjjt80mig	cmpfcqws200xjhkzbxd72s023	12	D	2026-05-21 10:33:12.287	2026-05-21 10:33:12.287
cmpfcrcdb00y7hkzbumo1uxpb	cmpfcqws200xjhkzbxd72s023	13	C	2026-05-21 10:33:12.287	2026-05-21 10:33:12.287
cmpfcrcdb00y9hkzbfceewaju	cmpfcqws200xjhkzbxd72s023	15	C	2026-05-21 10:33:12.287	2026-05-21 10:33:12.287
cmpfcrcdb00ybhkzb5c5x0ek5	cmpfcqws200xjhkzbxd72s023	16	B	2026-05-21 10:33:12.287	2026-05-21 10:33:12.287
cmpfcrcdb00ydhkzbugmq3ymv	cmpfcqws200xjhkzbxd72s023	17	B	2026-05-21 10:33:12.287	2026-05-21 10:33:12.287
cmpfcrcdb00yfhkzbb4dxv044	cmpfcqws200xjhkzbxd72s023	18	B	2026-05-21 10:33:12.287	2026-05-21 10:33:12.287
cmpfcrcdc00yhhkzbpailzr4c	cmpfcqws200xjhkzbxd72s023	19	D	2026-05-21 10:33:12.287	2026-05-21 10:33:12.287
cmpfcrcdc00yjhkzbpyn25h2u	cmpfcqws200xjhkzbxd72s023	20	E	2026-05-21 10:33:12.287	2026-05-21 10:33:12.287
cmpfcrk3500ylhkzbzc41rasj	cmpfcqws200xjhkzbxd72s023	21	D	2026-05-21 10:33:22.289	2026-05-21 10:33:22.289
cmpfcrk3500ynhkzbpkfn1p2k	cmpfcqws200xjhkzbxd72s023	22	C	2026-05-21 10:33:22.289	2026-05-21 10:33:22.289
cmpfcrk3600yphkzbhyp7lmoj	cmpfcqws200xjhkzbxd72s023	23	B	2026-05-21 10:33:22.289	2026-05-21 10:33:22.289
cmpfcrk3600yrhkzbhgaxxcbs	cmpfcqws200xjhkzbxd72s023	24	A	2026-05-21 10:33:22.289	2026-05-21 10:33:22.289
cmpfcrk3600ythkzbov2ihi2h	cmpfcqws200xjhkzbxd72s023	25	B	2026-05-21 10:33:22.289	2026-05-21 10:33:22.289
cmpfcrk3600yvhkzbdiqp4q41	cmpfcqws200xjhkzbxd72s023	26	A	2026-05-21 10:33:22.289	2026-05-21 10:33:22.289
cmpfcrk3600yxhkzbyc41phxr	cmpfcqws200xjhkzbxd72s023	27	C	2026-05-21 10:33:22.289	2026-05-21 10:33:22.289
cmpfcrk3600yzhkzbgrxsstn3	cmpfcqws200xjhkzbxd72s023	29	C	2026-05-21 10:33:22.289	2026-05-21 10:33:22.289
cmpfcrk3600z1hkzb0hx9izb6	cmpfcqws200xjhkzbxd72s023	30	C	2026-05-21 10:33:22.289	2026-05-21 10:33:22.289
cmpfcrk3700z3hkzbis1c7f6b	cmpfcqws200xjhkzbxd72s023	31	B	2026-05-21 10:33:22.289	2026-05-21 10:33:22.289
cmpfcrk3700z5hkzba125ga6w	cmpfcqws200xjhkzbxd72s023	32	D	2026-05-21 10:33:22.289	2026-05-21 10:33:22.289
cmpfcrk3700z7hkzb4lek354r	cmpfcqws200xjhkzbxd72s023	33	D	2026-05-21 10:33:22.289	2026-05-21 10:33:22.289
cmpfcrk3700z9hkzbtxasmz3b	cmpfcqws200xjhkzbxd72s023	34	D	2026-05-21 10:33:22.289	2026-05-21 10:33:22.289
cmpfcrk3700zbhkzbnoe6u6tj	cmpfcqws200xjhkzbxd72s023	35	C	2026-05-21 10:33:22.289	2026-05-21 10:33:22.289
cmpfcrqgl00zdhkzbk4a38h6k	cmpfcqws200xjhkzbxd72s023	36	B	2026-05-21 10:33:30.549	2026-05-21 10:33:30.549
cmpfcrqgm00zfhkzbjjsvhjdt	cmpfcqws200xjhkzbxd72s023	37	C	2026-05-21 10:33:30.549	2026-05-21 10:33:30.549
cmp8axe5p00o9hk5dg42eas4x	cmp8awh6l00mdhk5duk0hpxup	33	A	2026-05-16 12:07:32.077	2026-05-16 12:07:42.236
cmp8awmlw00mfhk5d8j947qk2	cmp8awh6l00mdhk5duk0hpxup	1	A	2026-05-16 12:06:56.372	2026-05-16 12:07:41.88
cmp8awn3900mhhk5d4i0bgknw	cmp8awh6l00mdhk5duk0hpxup	2	C	2026-05-16 12:06:56.997	2026-05-16 12:07:41.931
cmp8awolh00mnhk5dzvchsr1g	cmp8awh6l00mdhk5duk0hpxup	5	B	2026-05-16 12:06:58.949	2026-05-16 12:07:41.96
cmp8awpng00mrhk5dx8xa36ty	cmp8awh6l00mdhk5duk0hpxup	7	B	2026-05-16 12:07:00.317	2026-05-16 12:07:42.041
cmp8awni600mjhk5d3vhl1ndl	cmp8awh6l00mdhk5duk0hpxup	3	D	2026-05-16 12:06:57.534	2026-05-16 12:07:42.073
cmp8awrtj00mxhk5dpjnwi9bi	cmp8awh6l00mdhk5duk0hpxup	10	C	2026-05-16 12:07:03.127	2026-05-16 12:07:42.086
cmp8awtct00n1hk5dzm9k0zwv	cmp8awh6l00mdhk5duk0hpxup	12	C	2026-05-16 12:07:05.117	2026-05-16 12:07:42.114
cmp8awo1h00mlhk5dqpx2dv9e	cmp8awh6l00mdhk5duk0hpxup	4	C	2026-05-16 12:06:58.23	2026-05-16 12:07:42.113
cmp8awqby00mthk5dn73u3di7	cmp8awh6l00mdhk5duk0hpxup	8	E	2026-05-16 12:07:01.198	2026-05-16 12:07:42.118
cmp8awp6k00mphk5dwyxajqkf	cmp8awh6l00mdhk5duk0hpxup	6	A	2026-05-16 12:06:59.708	2026-05-16 12:07:42.115
cmp8ax8an00nxhk5d7j2134dv	cmp8awh6l00mdhk5duk0hpxup	27	D	2026-05-16 12:07:24.479	2026-05-16 12:07:42.144
cmp8awuz100n7hk5dcjc3s5yd	cmp8awh6l00mdhk5duk0hpxup	15	C	2026-05-16 12:07:07.213	2026-05-16 12:07:42.156
cmp8ax34f00nhhk5d0lmvuqte	cmp8awh6l00mdhk5duk0hpxup	19	A	2026-05-16 12:07:17.775	2026-05-16 12:07:42.156
cmp8awtqi00n3hk5dy78k5xsy	cmp8awh6l00mdhk5duk0hpxup	13	D	2026-05-16 12:07:05.61	2026-05-16 12:07:42.169
cmp8ax6o000nthk5d0v05qf53	cmp8awh6l00mdhk5duk0hpxup	25	E	2026-05-16 12:07:22.368	2026-05-16 12:07:42.179
cmp8aws9w00mzhk5dop23rsfb	cmp8awh6l00mdhk5duk0hpxup	11	C	2026-05-16 12:07:03.716	2026-05-16 12:07:42.19
cmp8awun000n5hk5dtqzhaltp	cmp8awh6l00mdhk5duk0hpxup	14	D	2026-05-16 12:07:06.781	2026-05-16 12:07:42.195
cmp8axdb200o7hk5da1z8k73w	cmp8awh6l00mdhk5duk0hpxup	32	B	2026-05-16 12:07:30.974	2026-05-16 12:07:42.195
cmp8ax58x00nnhk5dssi0kbwz	cmp8awh6l00mdhk5duk0hpxup	22	C	2026-05-16 12:07:20.529	2026-05-16 12:07:42.203
cmp8ax7q700nvhk5d5jeb3osh	cmp8awh6l00mdhk5duk0hpxup	26	E	2026-05-16 12:07:23.743	2026-05-16 12:07:42.214
cmp8ax4s800nlhk5dpt866gp8	cmp8awh6l00mdhk5duk0hpxup	21	B	2026-05-16 12:07:19.928	2026-05-16 12:07:42.223
cmp8awrax00mvhk5d37dtriux	cmp8awh6l00mdhk5duk0hpxup	9	D	2026-05-16 12:07:02.457	2026-05-16 12:07:42.229
cmp8axiym00olhk5dkb09vetn	cmp8awh6l00mdhk5duk0hpxup	40	B	2026-05-16 12:07:38.302	2026-05-16 12:07:42.23
cmp8axbbv00o3hk5dt38bmfr1	cmp8awh6l00mdhk5duk0hpxup	30	\N	2026-05-16 12:07:28.411	2026-05-16 12:07:42.244
cmp8ax65x00nrhk5d16ux4sc3	cmp8awh6l00mdhk5duk0hpxup	24	E	2026-05-16 12:07:21.717	2026-05-16 12:07:42.249
cmp8awvea00n9hk5dwbqeo7zr	cmp8awh6l00mdhk5duk0hpxup	16	D	2026-05-16 12:07:07.762	2026-05-16 12:07:42.259
cmp8ax9h600o1hk5d8y3ph520	cmp8awh6l00mdhk5duk0hpxup	29	B	2026-05-16 12:07:26.01	2026-05-16 12:07:42.264
cmp8axcp200o5hk5ddzqt9o8g	cmp8awh6l00mdhk5duk0hpxup	31	C	2026-05-16 12:07:30.182	2026-05-16 12:07:42.265
cmp8axf5800odhk5d7sg5opfs	cmp8awh6l00mdhk5duk0hpxup	35	B	2026-05-16 12:07:33.356	2026-05-16 12:07:42.277
cmp8ax8wp00nzhk5d43djz1aa	cmp8awh6l00mdhk5duk0hpxup	28	C	2026-05-16 12:07:25.273	2026-05-16 12:07:42.278
cmp8axh1n00ohhk5dyivjvmxq	cmp8awh6l00mdhk5duk0hpxup	38	B	2026-05-16 12:07:35.819	2026-05-16 12:07:42.287
cmp8ax1k600ndhk5d8um94rk7	cmp8awh6l00mdhk5duk0hpxup	17	C	2026-05-16 12:07:15.75	2026-05-16 12:07:42.294
cmp8ax5np00nphk5djt0abhpt	cmp8awh6l00mdhk5duk0hpxup	23	D	2026-05-16 12:07:21.061	2026-05-16 12:07:42.302
cmp8axhkf00ojhk5dkoidensm	cmp8awh6l00mdhk5duk0hpxup	39	D	2026-05-16 12:07:36.496	2026-05-16 12:07:42.311
cmp8ax21k00nfhk5dg2f3kp6k	cmp8awh6l00mdhk5duk0hpxup	18	B	2026-05-16 12:07:16.376	2026-05-16 12:07:42.317
cmp8axej700obhk5dpjy4x3v4	cmp8awh6l00mdhk5duk0hpxup	34	A	2026-05-16 12:07:32.563	2026-05-16 12:07:42.32
cmp8axg6t00ofhk5dpesk0u7v	cmp8awh6l00mdhk5duk0hpxup	37	E	2026-05-16 12:07:34.709	2026-05-16 12:07:42.322
cmpfcrqgm00zhhkzbzy9cj4jl	cmpfcqws200xjhkzbxd72s023	38	B	2026-05-21 10:33:30.549	2026-05-21 10:33:30.549
cmpfcrqgm00zjhkzbqz2my4pi	cmpfcqws200xjhkzbxd72s023	39	A	2026-05-21 10:33:30.549	2026-05-21 10:33:30.549
cmpfcrqgm00zlhkzbn85ujkli	cmpfcqws200xjhkzbxd72s023	40	E	2026-05-21 10:33:30.549	2026-05-21 10:33:30.549
cmpfcs3r700zphkzbbs7vgozs	cmpfcrvyl00znhkzbpaxyyzjd	1	A	2026-05-21 10:33:47.779	2026-05-21 10:33:47.779
cmpfcs3r700zrhkzbc64508am	cmpfcrvyl00znhkzbpaxyyzjd	2	C	2026-05-21 10:33:47.779	2026-05-21 10:33:47.779
cmpfcs3r800zthkzb426v69qy	cmpfcrvyl00znhkzbpaxyyzjd	3	D	2026-05-21 10:33:47.779	2026-05-21 10:33:47.779
cmpfcs3r800zvhkzbsrlv7q1o	cmpfcrvyl00znhkzbpaxyyzjd	4	E	2026-05-21 10:33:47.779	2026-05-21 10:33:47.779
cmpfcs3r800zxhkzbm3l50bey	cmpfcrvyl00znhkzbpaxyyzjd	5	B	2026-05-21 10:33:47.779	2026-05-21 10:33:47.779
cmpfcs3r800zzhkzbxq83w171	cmpfcrvyl00znhkzbpaxyyzjd	6	C	2026-05-21 10:33:47.779	2026-05-21 10:33:47.779
cmpfcs3r80101hkzbpbqvryzo	cmpfcrvyl00znhkzbpaxyyzjd	7	C	2026-05-21 10:33:47.779	2026-05-21 10:33:47.779
cmpfcs3r80103hkzbv6qgaqy6	cmpfcrvyl00znhkzbpaxyyzjd	8	B	2026-05-21 10:33:47.779	2026-05-21 10:33:47.779
cmpfcsbh90105hkzb6n5w4s2l	cmpfcrvyl00znhkzbpaxyyzjd	9	D	2026-05-21 10:33:57.787	2026-05-21 10:33:57.787
cmpfcsbh90107hkzbsibhao35	cmpfcrvyl00znhkzbpaxyyzjd	10	C	2026-05-21 10:33:57.787	2026-05-21 10:33:57.787
cmpfcsbh90109hkzbedp7w07l	cmpfcrvyl00znhkzbpaxyyzjd	11	B	2026-05-21 10:33:57.787	2026-05-21 10:33:57.787
cmpfcsbh9010bhkzb0djwh9yc	cmpfcrvyl00znhkzbpaxyyzjd	12	C	2026-05-21 10:33:57.787	2026-05-21 10:33:57.787
cmpfcsbha010dhkzbxzfpec81	cmpfcrvyl00znhkzbpaxyyzjd	13	D	2026-05-21 10:33:57.787	2026-05-21 10:33:57.787
cmpfcsbha010fhkzb3sqseu4h	cmpfcrvyl00znhkzbpaxyyzjd	14	C	2026-05-21 10:33:57.787	2026-05-21 10:33:57.787
cmpfcsbha010hhkzbubdwsi6v	cmpfcrvyl00znhkzbpaxyyzjd	15	B	2026-05-21 10:33:57.787	2026-05-21 10:33:57.787
cmpfcsj6y010jhkzbe1lrl87o	cmpfcrvyl00znhkzbpaxyyzjd	16	B	2026-05-21 10:34:07.786	2026-05-21 10:34:07.786
cmpfcsj6z010lhkzbh7a4eex7	cmpfcrvyl00znhkzbpaxyyzjd	17	D	2026-05-21 10:34:07.786	2026-05-21 10:34:07.786
cmpfcsj6z010nhkzbm1xjwkes	cmpfcrvyl00znhkzbpaxyyzjd	18	C	2026-05-21 10:34:07.786	2026-05-21 10:34:07.786
cmpfcsj6z010phkzbv54wnku1	cmpfcrvyl00znhkzbpaxyyzjd	19	B	2026-05-21 10:34:07.786	2026-05-21 10:34:07.786
cmpfcsj6z010rhkzb9vf5bem7	cmpfcrvyl00znhkzbpaxyyzjd	20	C	2026-05-21 10:34:07.786	2026-05-21 10:34:07.786
cmpfcsqwk010thkzb9docwa1w	cmpfcrvyl00znhkzbpaxyyzjd	21	C	2026-05-21 10:34:17.78	2026-05-21 10:34:17.78
cmpfcsqwk010vhkzb0aprxoau	cmpfcrvyl00znhkzbpaxyyzjd	23	D	2026-05-21 10:34:17.78	2026-05-21 10:34:17.78
cmpfcsqwk010xhkzb4wh4dyz3	cmpfcrvyl00znhkzbpaxyyzjd	24	B	2026-05-21 10:34:17.78	2026-05-21 10:34:17.78
cmpfcsqwk010zhkzb8khaxknj	cmpfcrvyl00znhkzbpaxyyzjd	26	A	2026-05-21 10:34:17.78	2026-05-21 10:34:17.78
cmpfcsqwk0111hkzb5q0g3ikc	cmpfcrvyl00znhkzbpaxyyzjd	27	C	2026-05-21 10:34:17.78	2026-05-21 10:34:17.78
cmpfcsqwl0113hkzbz6niygp0	cmpfcrvyl00znhkzbpaxyyzjd	28	D	2026-05-21 10:34:17.78	2026-05-21 10:34:17.78
cmpfcsqwl0115hkzbj0e0feri	cmpfcrvyl00znhkzbpaxyyzjd	30	C	2026-05-21 10:34:17.78	2026-05-21 10:34:17.78
cmpfcsqwl0117hkzb2blcwfaz	cmpfcrvyl00znhkzbpaxyyzjd	31	A	2026-05-21 10:34:17.78	2026-05-21 10:34:17.78
cmpfcsqwl0119hkzbprul1n71	cmpfcrvyl00znhkzbpaxyyzjd	32	A	2026-05-21 10:34:17.78	2026-05-21 10:34:17.78
cmpfcsqwl011bhkzbsagoit8p	cmpfcrvyl00znhkzbpaxyyzjd	33	B	2026-05-21 10:34:17.78	2026-05-21 10:34:17.78
cmpfcsqwl011dhkzbd4gmgrkr	cmpfcrvyl00znhkzbpaxyyzjd	34	C	2026-05-21 10:34:17.78	2026-05-21 10:34:17.78
cmpfcsqwm011fhkzbukd3yxyr	cmpfcrvyl00znhkzbpaxyyzjd	35	D	2026-05-21 10:34:17.78	2026-05-21 10:34:17.78
cmpfcsymt011hhkzbebbhwu2s	cmpfcrvyl00znhkzbpaxyyzjd	36	B	2026-05-21 10:34:27.797	2026-05-21 10:34:27.797
cmpfcsymu011jhkzbik4s58jk	cmpfcrvyl00znhkzbpaxyyzjd	38	C	2026-05-21 10:34:27.797	2026-05-21 10:34:27.797
cmpfcsymu011lhkzbzehc2f0l	cmpfcrvyl00znhkzbpaxyyzjd	39	D	2026-05-21 10:34:27.797	2026-05-21 10:34:27.797
cmpfcsymu011nhkzbwulxuv6z	cmpfcrvyl00znhkzbpaxyyzjd	40	A	2026-05-21 10:34:27.797	2026-05-21 10:34:27.797
cmpfcsymu011phkzbuz36ojy2	cmpfcrvyl00znhkzbpaxyyzjd	41	A	2026-05-21 10:34:27.797	2026-05-21 10:34:27.797
cmpfcsymu011rhkzbbz66fib4	cmpfcrvyl00znhkzbpaxyyzjd	42	B	2026-05-21 10:34:27.797	2026-05-21 10:34:27.797
cmpfcsymu011thkzb1c0f56m4	cmpfcrvyl00znhkzbpaxyyzjd	43	D	2026-05-21 10:34:27.797	2026-05-21 10:34:27.797
cmpfcsymv011vhkzb0ac7phq0	cmpfcrvyl00znhkzbpaxyyzjd	44	D	2026-05-21 10:34:27.797	2026-05-21 10:34:27.797
cmpfcsymv011xhkzbj1mslazd	cmpfcrvyl00znhkzbpaxyyzjd	45	E	2026-05-21 10:34:27.797	2026-05-21 10:34:27.797
cmpfcsymv011zhkzb41bdt5wd	cmpfcrvyl00znhkzbpaxyyzjd	46	B	2026-05-21 10:34:27.797	2026-05-21 10:34:27.797
cmpfcsymv0121hkzb1pt51big	cmpfcrvyl00znhkzbpaxyyzjd	47	B	2026-05-21 10:34:27.797	2026-05-21 10:34:27.797
cmpfcsymv0123hkzbldyty5vd	cmpfcrvyl00znhkzbpaxyyzjd	48	B	2026-05-21 10:34:27.797	2026-05-21 10:34:27.797
cmpfcsymx0125hkzbz9q2q2qy	cmpfcrvyl00znhkzbpaxyyzjd	49	C	2026-05-21 10:34:27.797	2026-05-21 10:34:27.797
cmpfct6cd0127hkzbd4hf76r8	cmpfcrvyl00znhkzbpaxyyzjd	50	C	2026-05-21 10:34:37.789	2026-05-21 10:34:37.789
cmpfct6cd0129hkzb51cdmnpn	cmpfcrvyl00znhkzbpaxyyzjd	51	D	2026-05-21 10:34:37.789	2026-05-21 10:34:37.789
cmpfct6ce012bhkzb538s3gt6	cmpfcrvyl00znhkzbpaxyyzjd	52	B	2026-05-21 10:34:37.789	2026-05-21 10:34:37.789
cmpfct6ce012dhkzb6gdtuywc	cmpfcrvyl00znhkzbpaxyyzjd	53	D	2026-05-21 10:34:37.789	2026-05-21 10:34:37.789
cmpfct6ce012fhkzbm6lsxyet	cmpfcrvyl00znhkzbpaxyyzjd	55	C	2026-05-21 10:34:37.789	2026-05-21 10:34:37.789
cmpfct6ce012hhkzbvl427t45	cmpfcrvyl00znhkzbpaxyyzjd	57	A	2026-05-21 10:34:37.789	2026-05-21 10:34:37.789
cmpfct6ce012jhkzbirjbo661	cmpfcrvyl00znhkzbpaxyyzjd	58	E	2026-05-21 10:34:37.789	2026-05-21 10:34:37.789
cmpfct6ce012lhkzbp0ptuvdf	cmpfcrvyl00znhkzbpaxyyzjd	59	E	2026-05-21 10:34:37.789	2026-05-21 10:34:37.789
cmpfct6ce012nhkzb474z14qb	cmpfcrvyl00znhkzbpaxyyzjd	60	C	2026-05-21 10:34:37.789	2026-05-21 10:34:37.789
cmpfcte23012phkzbna5sv40a	cmpfcrvyl00znhkzbpaxyyzjd	61	C	2026-05-21 10:34:47.785	2026-05-21 10:34:47.785
cmpfcte23012rhkzbblkqxs2z	cmpfcrvyl00znhkzbpaxyyzjd	62	A	2026-05-21 10:34:47.785	2026-05-21 10:34:47.785
cmpfcte23012thkzbwzuw0fdw	cmpfcrvyl00znhkzbpaxyyzjd	63	C	2026-05-21 10:34:47.785	2026-05-21 10:34:47.785
cmpfcte23012vhkzbn12estbo	cmpfcrvyl00znhkzbpaxyyzjd	64	D	2026-05-21 10:34:47.785	2026-05-21 10:34:47.785
cmpfcte23012xhkzb7xrs4hjn	cmpfcrvyl00znhkzbpaxyyzjd	65	E	2026-05-21 10:34:47.785	2026-05-21 10:34:47.785
cmpfcte24012zhkzbue2uin3e	cmpfcrvyl00znhkzbpaxyyzjd	66	E	2026-05-21 10:34:47.785	2026-05-21 10:34:47.785
cmpfcte240131hkzbgyenmhni	cmpfcrvyl00znhkzbpaxyyzjd	67	C	2026-05-21 10:34:47.785	2026-05-21 10:34:47.785
cmpfcte240133hkzbeo03kdrr	cmpfcrvyl00znhkzbpaxyyzjd	69	C	2026-05-21 10:34:47.785	2026-05-21 10:34:47.785
cmpfcte240135hkzb9qvlr1n9	cmpfcrvyl00znhkzbpaxyyzjd	70	A	2026-05-21 10:34:47.785	2026-05-21 10:34:47.785
cmpfcte240137hkzb0qkyiogy	cmpfcrvyl00znhkzbpaxyyzjd	71	A	2026-05-21 10:34:47.785	2026-05-21 10:34:47.785
cmpfctls80139hkzbl1xy7ul9	cmpfcrvyl00znhkzbpaxyyzjd	72	B	2026-05-21 10:34:57.8	2026-05-21 10:34:57.8
cmpfctls9013bhkzblncot7uf	cmpfcrvyl00znhkzbpaxyyzjd	74	D	2026-05-21 10:34:57.8	2026-05-21 10:34:57.8
cmpfctls9013dhkzbifrnwhe5	cmpfcrvyl00znhkzbpaxyyzjd	75	B	2026-05-21 10:34:57.8	2026-05-21 10:34:57.8
cmpfctls9013fhkzbv9sndjgp	cmpfcrvyl00znhkzbpaxyyzjd	76	E	2026-05-21 10:34:57.8	2026-05-21 10:34:57.8
cmpfctls9013hhkzbhv7px0bx	cmpfcrvyl00znhkzbpaxyyzjd	77	D	2026-05-21 10:34:57.8	2026-05-21 10:34:57.8
cmpfctls9013jhkzbwkizsbo9	cmpfcrvyl00znhkzbpaxyyzjd	79	C	2026-05-21 10:34:57.8	2026-05-21 10:34:57.8
cmpfctls9013lhkzb0gw6v07g	cmpfcrvyl00znhkzbpaxyyzjd	80	D	2026-05-21 10:34:57.8	2026-05-21 10:34:57.8
cmpfctlsa013nhkzb2pl4mrs7	cmpfcrvyl00znhkzbpaxyyzjd	81	E	2026-05-21 10:34:57.8	2026-05-21 10:34:57.8
cmpfctthv013phkzb9wkwygq2	cmpfcrvyl00znhkzbpaxyyzjd	82	C	2026-05-21 10:35:07.795	2026-05-21 10:35:07.795
cmpfctthw013rhkzb1gzcz0vu	cmpfcrvyl00znhkzbpaxyyzjd	83	B	2026-05-21 10:35:07.795	2026-05-21 10:35:07.795
cmpfctthw013thkzb55dron2m	cmpfcrvyl00znhkzbpaxyyzjd	84	D	2026-05-21 10:35:07.795	2026-05-21 10:35:07.795
cmpfctthw013vhkzb7pgc5h3l	cmpfcrvyl00znhkzbpaxyyzjd	86	C	2026-05-21 10:35:07.795	2026-05-21 10:35:07.795
cmpfcu17a013xhkzb1qskjh6b	cmpfcrvyl00znhkzbpaxyyzjd	87	B	2026-05-21 10:35:17.782	2026-05-21 10:35:17.782
cmpfcu17a013zhkzbdqukql3g	cmpfcrvyl00znhkzbpaxyyzjd	89	C	2026-05-21 10:35:17.782	2026-05-21 10:35:17.782
cmpfcu17a0141hkzbgyvih6sd	cmpfcrvyl00znhkzbpaxyyzjd	90	D	2026-05-21 10:35:17.782	2026-05-21 10:35:17.782
cmpfcu17b0143hkzbtxcxbzb7	cmpfcrvyl00znhkzbpaxyyzjd	91	E	2026-05-21 10:35:17.782	2026-05-21 10:35:17.782
cmpfcu17b0145hkzbv0zavypy	cmpfcrvyl00znhkzbpaxyyzjd	92	C	2026-05-21 10:35:17.782	2026-05-21 10:35:17.782
cmpfcu17b0147hkzbkywyw4fz	cmpfcrvyl00znhkzbpaxyyzjd	93	B	2026-05-21 10:35:17.782	2026-05-21 10:35:17.782
cmpfcu8wz0149hkzbsno5ozv4	cmpfcrvyl00znhkzbpaxyyzjd	94	D	2026-05-21 10:35:27.779	2026-05-21 10:35:27.779
cmpfcu8wz014bhkzbqnof80kv	cmpfcrvyl00znhkzbpaxyyzjd	95	C	2026-05-21 10:35:27.779	2026-05-21 10:35:27.779
cmpfcu8wz014dhkzblumvlost	cmpfcrvyl00znhkzbpaxyyzjd	96	B	2026-05-21 10:35:27.779	2026-05-21 10:35:27.779
cmpfcu8x0014fhkzb80q6tg93	cmpfcrvyl00znhkzbpaxyyzjd	97	C	2026-05-21 10:35:27.779	2026-05-21 10:35:27.779
cmpfcugmr014hhkzb6f81xy56	cmpfcrvyl00znhkzbpaxyyzjd	98	D	2026-05-21 10:35:37.779	2026-05-21 10:35:37.779
cmpfcugms014jhkzb2y0rkqm0	cmpfcrvyl00znhkzbpaxyyzjd	99	C	2026-05-21 10:35:37.779	2026-05-21 10:35:37.779
cmpfcugms014lhkzb80h31qt7	cmpfcrvyl00znhkzbpaxyyzjd	100	B	2026-05-21 10:35:37.779	2026-05-21 10:35:37.779
cmpfcugms014nhkzbm8f7tsnn	cmpfcrvyl00znhkzbpaxyyzjd	102	D	2026-05-21 10:35:37.779	2026-05-21 10:35:37.779
cmpfcugms014phkzbtagb9mme	cmpfcrvyl00znhkzbpaxyyzjd	103	A	2026-05-21 10:35:37.779	2026-05-21 10:35:37.779
cmpfcuocl014rhkzbm6ytxwup	cmpfcrvyl00znhkzbpaxyyzjd	104	A	2026-05-21 10:35:47.781	2026-05-21 10:35:47.781
cmpfcuocl014thkzbw4qxokmg	cmpfcrvyl00znhkzbpaxyyzjd	105	B	2026-05-21 10:35:47.781	2026-05-21 10:35:47.781
cmpfcuocl014vhkzbirnar758	cmpfcrvyl00znhkzbpaxyyzjd	106	C	2026-05-21 10:35:47.781	2026-05-21 10:35:47.781
cmpfcuocl014xhkzb95m4heqz	cmpfcrvyl00znhkzbpaxyyzjd	107	D	2026-05-21 10:35:47.781	2026-05-21 10:35:47.781
cmpfcuocl014zhkzbsaf8ecp9	cmpfcrvyl00znhkzbpaxyyzjd	108	C	2026-05-21 10:35:47.781	2026-05-21 10:35:47.781
cmpfcuocm0151hkzbmmj6ki2v	cmpfcrvyl00znhkzbpaxyyzjd	109	C	2026-05-21 10:35:47.781	2026-05-21 10:35:47.781
cmpfcuocm0153hkzbe70uaw9c	cmpfcrvyl00znhkzbpaxyyzjd	110	D	2026-05-21 10:35:47.781	2026-05-21 10:35:47.781
cmpfcuocm0155hkzbvx72y4i1	cmpfcrvyl00znhkzbpaxyyzjd	111	A	2026-05-21 10:35:47.781	2026-05-21 10:35:47.781
cmpfcuocm0157hkzbetmvj7ou	cmpfcrvyl00znhkzbpaxyyzjd	112	B	2026-05-21 10:35:47.781	2026-05-21 10:35:47.781
cmpfcuw2m0159hkzb0f12hvcn	cmpfcrvyl00znhkzbpaxyyzjd	113	C	2026-05-21 10:35:57.79	2026-05-21 10:35:57.79
cmpfcuw2m015bhkzb6p95dwtb	cmpfcrvyl00znhkzbpaxyyzjd	114	C	2026-05-21 10:35:57.79	2026-05-21 10:35:57.79
cmpfcuw2n015dhkzbdc4zec27	cmpfcrvyl00znhkzbpaxyyzjd	115	B	2026-05-21 10:35:57.79	2026-05-21 10:35:57.79
cmpfcuw2n015fhkzbg11tepkr	cmpfcrvyl00znhkzbpaxyyzjd	116	A	2026-05-21 10:35:57.79	2026-05-21 10:35:57.79
cmpfcuw2n015hhkzbcb5ehftd	cmpfcrvyl00znhkzbpaxyyzjd	118	C	2026-05-21 10:35:57.79	2026-05-21 10:35:57.79
cmpfcv3sb015jhkzb6s39sp9r	cmpfcrvyl00znhkzbpaxyyzjd	117	D	2026-05-21 10:36:07.785	2026-05-21 10:36:07.785
cmpfcv3sb015lhkzb60uw3l7t	cmpfcrvyl00znhkzbpaxyyzjd	119	B	2026-05-21 10:36:07.785	2026-05-21 10:36:07.785
cmpfcv3sb015nhkzbh4xwhoot	cmpfcrvyl00znhkzbpaxyyzjd	120	D	2026-05-21 10:36:07.785	2026-05-21 10:36:07.785
cmpfcwr8e015rhkzbukt9rn5d	cmpfcw40h015phkzbh0mvsm8u	1	D	2026-05-21 10:37:24.828	2026-05-21 10:37:24.828
cmpfcwr8e015thkzbg5g8yjg4	cmpfcw40h015phkzbh0mvsm8u	2	C	2026-05-21 10:37:24.828	2026-05-21 10:37:24.828
cmpfcwr8e015vhkzb2mz2yfup	cmpfcw40h015phkzbh0mvsm8u	3	D	2026-05-21 10:37:24.828	2026-05-21 10:37:24.828
cmpfcwr8e015xhkzbbozb2mhr	cmpfcw40h015phkzbh0mvsm8u	4	D	2026-05-21 10:37:24.828	2026-05-21 10:37:24.828
cmpfcwr8e015zhkzbm8isr75o	cmpfcw40h015phkzbh0mvsm8u	5	D	2026-05-21 10:37:24.828	2026-05-21 10:37:24.828
cmpfcwr8e0161hkzb5yezrkdm	cmpfcw40h015phkzbh0mvsm8u	6	D	2026-05-21 10:37:24.828	2026-05-21 10:37:24.828
cmpfcwyxz0163hkzbm81je6mf	cmpfcw40h015phkzbh0mvsm8u	7	C	2026-05-21 10:37:34.822	2026-05-21 10:37:34.822
cmpfcwyxz0165hkzb2r8a280z	cmpfcw40h015phkzbh0mvsm8u	8	C	2026-05-21 10:37:34.822	2026-05-21 10:37:34.822
cmpfcwyxz0167hkzbsi2pi848	cmpfcw40h015phkzbh0mvsm8u	9	D	2026-05-21 10:37:34.822	2026-05-21 10:37:34.822
cmpfcwyxz0169hkzbomjlycfl	cmpfcw40h015phkzbh0mvsm8u	10	D	2026-05-21 10:37:34.822	2026-05-21 10:37:34.822
cmpfcwyxz016bhkzb00pccom3	cmpfcw40h015phkzbh0mvsm8u	11	C	2026-05-21 10:37:34.822	2026-05-21 10:37:34.822
cmpfcwyxz016dhkzbsca882k3	cmpfcw40h015phkzbh0mvsm8u	12	D	2026-05-21 10:37:34.822	2026-05-21 10:37:34.822
cmpfcwyxz016fhkzb8dcor32x	cmpfcw40h015phkzbh0mvsm8u	13	D	2026-05-21 10:37:34.822	2026-05-21 10:37:34.822
cmpfcx6nl016hhkzba3foy6bf	cmpfcw40h015phkzbh0mvsm8u	14	C	2026-05-21 10:37:44.817	2026-05-21 10:37:44.817
cmpfcx6nl016jhkzbg2ncxp8u	cmpfcw40h015phkzbh0mvsm8u	15	C	2026-05-21 10:37:44.817	2026-05-21 10:37:44.817
cmpfcx6nm016lhkzbqciic6gr	cmpfcw40h015phkzbh0mvsm8u	16	D	2026-05-21 10:37:44.817	2026-05-21 10:37:44.817
cmpfcx6nm016nhkzblqlcgqqf	cmpfcw40h015phkzbh0mvsm8u	17	D	2026-05-21 10:37:44.817	2026-05-21 10:37:44.817
cmpfcx6nm016phkzbjc29c4fz	cmpfcw40h015phkzbh0mvsm8u	18	C	2026-05-21 10:37:44.817	2026-05-21 10:37:44.817
cmpfcx6nm016rhkzb4mwia8yx	cmpfcw40h015phkzbh0mvsm8u	19	C	2026-05-21 10:37:44.817	2026-05-21 10:37:44.817
cmpfcx6nm016thkzb9q1fekga	cmpfcw40h015phkzbh0mvsm8u	20	C	2026-05-21 10:37:44.817	2026-05-21 10:37:44.817
cmpfcx6nm016vhkzbtudhxvju	cmpfcw40h015phkzbh0mvsm8u	21	C	2026-05-21 10:37:44.817	2026-05-21 10:37:44.817
cmpfcx6nm016xhkzbfps3k2nj	cmpfcw40h015phkzbh0mvsm8u	22	D	2026-05-21 10:37:44.817	2026-05-21 10:37:44.817
cmpfcxedp016zhkzbvuqfo7ex	cmpfcw40h015phkzbh0mvsm8u	23	D	2026-05-21 10:37:54.827	2026-05-21 10:37:54.827
cmpfcxedp0171hkzbuib2rm8o	cmpfcw40h015phkzbh0mvsm8u	24	D	2026-05-21 10:37:54.827	2026-05-21 10:37:54.827
cmpfcxedp0173hkzbevgw7i68	cmpfcw40h015phkzbh0mvsm8u	25	D	2026-05-21 10:37:54.827	2026-05-21 10:37:54.827
cmpfcxedp0175hkzbythbav8i	cmpfcw40h015phkzbh0mvsm8u	26	D	2026-05-21 10:37:54.827	2026-05-21 10:37:54.827
cmpfcxedq0177hkzbl2ihivsd	cmpfcw40h015phkzbh0mvsm8u	27	C	2026-05-21 10:37:54.827	2026-05-21 10:37:54.827
cmpfcxedq0179hkzblx9067gr	cmpfcw40h015phkzbh0mvsm8u	28	C	2026-05-21 10:37:54.827	2026-05-21 10:37:54.827
cmpfcxedq017bhkzbcdph6a65	cmpfcw40h015phkzbh0mvsm8u	29	D	2026-05-21 10:37:54.827	2026-05-21 10:37:54.827
cmpfcxedq017dhkzb93pj8jt7	cmpfcw40h015phkzbh0mvsm8u	30	C	2026-05-21 10:37:54.827	2026-05-21 10:37:54.827
cmpfcxedq017fhkzbw5d2ue1x	cmpfcw40h015phkzbh0mvsm8u	31	C	2026-05-21 10:37:54.827	2026-05-21 10:37:54.827
cmpfcxm39017hhkzbb4ro10yq	cmpfcw40h015phkzbh0mvsm8u	32	E	2026-05-21 10:38:04.821	2026-05-21 10:38:04.821
cmpfcxm39017jhkzbd7ka0gi6	cmpfcw40h015phkzbh0mvsm8u	33	B	2026-05-21 10:38:04.821	2026-05-21 10:38:04.821
cmpfcxm3a017lhkzbjf9ehjst	cmpfcw40h015phkzbh0mvsm8u	34	D	2026-05-21 10:38:04.821	2026-05-21 10:38:04.821
cmpfcxm3a017nhkzb4yawsh90	cmpfcw40h015phkzbh0mvsm8u	35	C	2026-05-21 10:38:04.821	2026-05-21 10:38:04.821
cmpfcxm3a017phkzbr3zfdr7i	cmpfcw40h015phkzbh0mvsm8u	36	D	2026-05-21 10:38:04.821	2026-05-21 10:38:04.821
cmpfcxm3a017rhkzboyglvqi4	cmpfcw40h015phkzbh0mvsm8u	37	C	2026-05-21 10:38:04.821	2026-05-21 10:38:04.821
cmpfcxm3a017thkzbltevmnjt	cmpfcw40h015phkzbh0mvsm8u	38	C	2026-05-21 10:38:04.821	2026-05-21 10:38:04.821
cmpfcxm3a017vhkzbc22fz1ma	cmpfcw40h015phkzbh0mvsm8u	39	C	2026-05-21 10:38:04.821	2026-05-21 10:38:04.821
cmpfcxoyn017xhkzb9oabpnw5	cmpfcw40h015phkzbh0mvsm8u	40	A	2026-05-21 10:38:08.544	2026-05-21 10:38:08.544
cmpfcxyma0181hkzbyc9j1g1l	cmpfcxqu9017zhkzb8biuvh51	1	A	2026-05-21 10:38:21.058	2026-05-21 10:38:21.058
cmpfcxyma0183hkzb1bl2c7qn	cmpfcxqu9017zhkzb8biuvh51	2	C	2026-05-21 10:38:21.058	2026-05-21 10:38:21.058
cmpfcxyma0185hkzb9pfmpmiy	cmpfcxqu9017zhkzb8biuvh51	3	C	2026-05-21 10:38:21.058	2026-05-21 10:38:21.058
cmpfcxyma0187hkzbgpw0xetv	cmpfcxqu9017zhkzb8biuvh51	4	B	2026-05-21 10:38:21.058	2026-05-21 10:38:21.058
cmpfcxymb0189hkzbpecpwcip	cmpfcxqu9017zhkzb8biuvh51	5	C	2026-05-21 10:38:21.058	2026-05-21 10:38:21.058
cmpfcxymb018bhkzbv6mmdof5	cmpfcxqu9017zhkzb8biuvh51	6	D	2026-05-21 10:38:21.058	2026-05-21 10:38:21.058
cmpfcxymb018dhkzbfno4oifa	cmpfcxqu9017zhkzb8biuvh51	7	D	2026-05-21 10:38:21.058	2026-05-21 10:38:21.058
cmpfcy6c3018fhkzb8zf9gieu	cmpfcxqu9017zhkzb8biuvh51	8	C	2026-05-21 10:38:31.059	2026-05-21 10:38:31.059
cmpfcy6c3018hhkzb8xqu7f18	cmpfcxqu9017zhkzb8biuvh51	9	D	2026-05-21 10:38:31.059	2026-05-21 10:38:31.059
cmpfcy6c3018jhkzbpaoooeiz	cmpfcxqu9017zhkzb8biuvh51	10	D	2026-05-21 10:38:31.059	2026-05-21 10:38:31.059
cmpfcy6c4018lhkzb9tz3a5il	cmpfcxqu9017zhkzb8biuvh51	11	D	2026-05-21 10:38:31.059	2026-05-21 10:38:31.059
cmpfcy6c4018nhkzbsxbuimvr	cmpfcxqu9017zhkzb8biuvh51	12	C	2026-05-21 10:38:31.059	2026-05-21 10:38:31.059
cmpfcy6c4018phkzbh8y48ezj	cmpfcxqu9017zhkzb8biuvh51	13	A	2026-05-21 10:38:31.059	2026-05-21 10:38:31.059
cmpfcy6c4018rhkzb4vhxyltd	cmpfcxqu9017zhkzb8biuvh51	14	A	2026-05-21 10:38:31.059	2026-05-21 10:38:31.059
cmpfcy6c4018thkzb6eao8luz	cmpfcxqu9017zhkzb8biuvh51	15	A	2026-05-21 10:38:31.059	2026-05-21 10:38:31.059
cmpfcy6c4018vhkzbegn690e8	cmpfcxqu9017zhkzb8biuvh51	16	B	2026-05-21 10:38:31.059	2026-05-21 10:38:31.059
cmpfcye1w018xhkzbcaenrfrf	cmpfcxqu9017zhkzb8biuvh51	17	B	2026-05-21 10:38:41.059	2026-05-21 10:38:41.059
cmpfcye1w018zhkzbqbcl8bvy	cmpfcxqu9017zhkzb8biuvh51	18	B	2026-05-21 10:38:41.059	2026-05-21 10:38:41.059
cmpfcye1w0191hkzbm2c9ni8r	cmpfcxqu9017zhkzb8biuvh51	19	C	2026-05-21 10:38:41.059	2026-05-21 10:38:41.059
cmpfcye1w0193hkzb4xqwf51b	cmpfcxqu9017zhkzb8biuvh51	20	C	2026-05-21 10:38:41.059	2026-05-21 10:38:41.059
cmpfcye1w0195hkzbpeg6lkkg	cmpfcxqu9017zhkzb8biuvh51	21	C	2026-05-21 10:38:41.059	2026-05-21 10:38:41.059
cmpfcye1x0197hkzbhyq81syi	cmpfcxqu9017zhkzb8biuvh51	22	E	2026-05-21 10:38:41.059	2026-05-21 10:38:41.059
cmpfcye1x0199hkzbqc7xjh39	cmpfcxqu9017zhkzb8biuvh51	23	C	2026-05-21 10:38:41.059	2026-05-21 10:38:41.059
cmpfcye1x019bhkzbi4gph5d1	cmpfcxqu9017zhkzb8biuvh51	24	C	2026-05-21 10:38:41.059	2026-05-21 10:38:41.059
cmpfcye1x019dhkzb65qlpa0q	cmpfcxqu9017zhkzb8biuvh51	25	B	2026-05-21 10:38:41.059	2026-05-21 10:38:41.059
cmpfcye1x019fhkzb9rv3id6a	cmpfcxqu9017zhkzb8biuvh51	26	D	2026-05-21 10:38:41.059	2026-05-21 10:38:41.059
cmpfcye1x019hhkzbconpszlw	cmpfcxqu9017zhkzb8biuvh51	27	B	2026-05-21 10:38:41.059	2026-05-21 10:38:41.059
cmpfcylrm019jhkzb6jjp9tft	cmpfcxqu9017zhkzb8biuvh51	28	D	2026-05-21 10:38:51.058	2026-05-21 10:38:51.058
cmpfcylrn019lhkzbiwk68egu	cmpfcxqu9017zhkzb8biuvh51	29	C	2026-05-21 10:38:51.058	2026-05-21 10:38:51.058
cmpfcylrn019nhkzbn870jrys	cmpfcxqu9017zhkzb8biuvh51	30	E	2026-05-21 10:38:51.058	2026-05-21 10:38:51.058
cmpfcylrn019phkzb8t16rvaq	cmpfcxqu9017zhkzb8biuvh51	31	D	2026-05-21 10:38:51.058	2026-05-21 10:38:51.058
cmpfcytho019rhkzb4awnqgp1	cmpfcxqu9017zhkzb8biuvh51	32	C	2026-05-21 10:39:01.068	2026-05-21 10:39:01.068
cmpfcytho019thkzbxz0ffgit	cmpfcxqu9017zhkzb8biuvh51	33	B	2026-05-21 10:39:01.068	2026-05-21 10:39:01.068
cmpfcytho019vhkzbhwm6n22v	cmpfcxqu9017zhkzb8biuvh51	34	B	2026-05-21 10:39:01.068	2026-05-21 10:39:01.068
cmpfcythp019xhkzbkaxu5lcu	cmpfcxqu9017zhkzb8biuvh51	35	D	2026-05-21 10:39:01.068	2026-05-21 10:39:01.068
cmpfcythp019zhkzb8hqqh6t3	cmpfcxqu9017zhkzb8biuvh51	36	D	2026-05-21 10:39:01.068	2026-05-21 10:39:01.068
cmpfcythp01a1hkzbvufc2p9b	cmpfcxqu9017zhkzb8biuvh51	37	D	2026-05-21 10:39:01.068	2026-05-21 10:39:01.068
cmpfcythp01a3hkzb7mi3j2nc	cmpfcxqu9017zhkzb8biuvh51	38	B	2026-05-21 10:39:01.068	2026-05-21 10:39:01.068
cmpfcythr01a5hkzb2410qe4q	cmpfcxqu9017zhkzb8biuvh51	39	D	2026-05-21 10:39:01.068	2026-05-21 10:39:01.068
cmpfcz08h01a7hkzbydyby9uy	cmpfcxqu9017zhkzb8biuvh51	40	C	2026-05-21 10:39:09.808	2026-05-21 10:39:09.808
cmpfczajx01abhkzb94ciw9xu	cmpfcz2rw01a9hkzb9jckvy6i	2	D	2026-05-21 10:39:23.181	2026-05-21 10:39:23.181
cmpfczajy01adhkzbjh6oedxx	cmpfcz2rw01a9hkzb9jckvy6i	4	D	2026-05-21 10:39:23.181	2026-05-21 10:39:23.181
cmpfczajy01afhkzb91iacx96	cmpfcz2rw01a9hkzb9jckvy6i	5	B	2026-05-21 10:39:23.181	2026-05-21 10:39:23.181
cmpfczajy01ahhkzb5odyohr4	cmpfcz2rw01a9hkzb9jckvy6i	6	C	2026-05-21 10:39:23.181	2026-05-21 10:39:23.181
cmpfczajy01ajhkzb0nmu0h9z	cmpfcz2rw01a9hkzb9jckvy6i	7	D	2026-05-21 10:39:23.181	2026-05-21 10:39:23.181
cmpfczi9k01alhkzba8t81zjq	cmpfcz2rw01a9hkzb9jckvy6i	8	A	2026-05-21 10:39:33.176	2026-05-21 10:39:33.176
cmpfczi9k01anhkzbzr4iy43m	cmpfcz2rw01a9hkzb9jckvy6i	9	C	2026-05-21 10:39:33.176	2026-05-21 10:39:33.176
cmpfczi9l01aphkzbdmf80hx4	cmpfcz2rw01a9hkzb9jckvy6i	10	E	2026-05-21 10:39:33.176	2026-05-21 10:39:33.176
cmpfczi9l01arhkzbi3l29x5d	cmpfcz2rw01a9hkzb9jckvy6i	11	C	2026-05-21 10:39:33.176	2026-05-21 10:39:33.176
cmpfczi9l01athkzbmzh4wt0i	cmpfcz2rw01a9hkzb9jckvy6i	12	C	2026-05-21 10:39:33.176	2026-05-21 10:39:33.176
cmpfczi9l01avhkzb1571jnbj	cmpfcz2rw01a9hkzb9jckvy6i	13	E	2026-05-21 10:39:33.176	2026-05-21 10:39:33.176
cmpfczi9l01axhkzbcdfwm41e	cmpfcz2rw01a9hkzb9jckvy6i	14	B	2026-05-21 10:39:33.176	2026-05-21 10:39:33.176
cmpfczi9m01azhkzbveqwa5mx	cmpfcz2rw01a9hkzb9jckvy6i	15	D	2026-05-21 10:39:33.176	2026-05-21 10:39:33.176
cmpfczi9m01b1hkzbmerzr7l5	cmpfcz2rw01a9hkzb9jckvy6i	16	C	2026-05-21 10:39:33.176	2026-05-21 10:39:33.176
cmpfczpzj01b3hkzb41jlojqx	cmpfcz2rw01a9hkzb9jckvy6i	17	D	2026-05-21 10:39:43.182	2026-05-21 10:39:43.182
cmpfczpzj01b5hkzb40qtv15f	cmpfcz2rw01a9hkzb9jckvy6i	18	D	2026-05-21 10:39:43.182	2026-05-21 10:39:43.182
cmpfczpzl01b7hkzbrozess82	cmpfcz2rw01a9hkzb9jckvy6i	19	B	2026-05-21 10:39:43.182	2026-05-21 10:39:43.182
cmpfczpzm01b9hkzbec1aq045	cmpfcz2rw01a9hkzb9jckvy6i	21	B	2026-05-21 10:39:43.182	2026-05-21 10:39:43.182
cmpfczpzm01bbhkzbf3tz8z1d	cmpfcz2rw01a9hkzb9jckvy6i	22	A	2026-05-21 10:39:43.182	2026-05-21 10:39:43.182
cmpfczpzm01bdhkzbe36pwn97	cmpfcz2rw01a9hkzb9jckvy6i	23	B	2026-05-21 10:39:43.182	2026-05-21 10:39:43.182
cmpfczpzm01bfhkzbzjqg8tnn	cmpfcz2rw01a9hkzb9jckvy6i	24	D	2026-05-21 10:39:43.182	2026-05-21 10:39:43.182
cmpfczpzm01bhhkzbp7n5clax	cmpfcz2rw01a9hkzb9jckvy6i	25	E	2026-05-21 10:39:43.182	2026-05-21 10:39:43.182
cmpfczpzn01bjhkzbyd3ehnrq	cmpfcz2rw01a9hkzb9jckvy6i	27	C	2026-05-21 10:39:43.182	2026-05-21 10:39:43.182
cmpfczpzn01blhkzbxk2aiqgm	cmpfcz2rw01a9hkzb9jckvy6i	28	C	2026-05-21 10:39:43.182	2026-05-21 10:39:43.182
cmpfczxph01bnhkzbjscl3bes	cmpfcz2rw01a9hkzb9jckvy6i	26	D	2026-05-21 10:39:53.189	2026-05-21 10:39:53.189
cmpfczxpi01bphkzb3l4fo7d2	cmpfcz2rw01a9hkzb9jckvy6i	29	B	2026-05-21 10:39:53.189	2026-05-21 10:39:53.189
cmpfczxpi01brhkzbidhgweaa	cmpfcz2rw01a9hkzb9jckvy6i	32	E	2026-05-21 10:39:53.189	2026-05-21 10:39:53.189
cmpfczxpi01bthkzbrvcys742	cmpfcz2rw01a9hkzb9jckvy6i	33	D	2026-05-21 10:39:53.189	2026-05-21 10:39:53.189
cmpfczxpi01bvhkzbjnbkts7i	cmpfcz2rw01a9hkzb9jckvy6i	34	C	2026-05-21 10:39:53.189	2026-05-21 10:39:53.189
cmpfczxpi01bxhkzbf2r62ycd	cmpfcz2rw01a9hkzb9jckvy6i	35	B	2026-05-21 10:39:53.189	2026-05-21 10:39:53.189
cmpfczxpj01bzhkzbf3fjkpqx	cmpfcz2rw01a9hkzb9jckvy6i	36	A	2026-05-21 10:39:53.189	2026-05-21 10:39:53.189
cmpfd02q901c1hkzb9vgpdskb	cmpfcz2rw01a9hkzb9jckvy6i	37	B	2026-05-21 10:39:59.694	2026-05-21 10:39:59.694
cmpfd02q901c3hkzbvv55n7bh	cmpfcz2rw01a9hkzb9jckvy6i	38	C	2026-05-21 10:39:59.694	2026-05-21 10:39:59.694
cmpfd02q901c5hkzbskreqj3m	cmpfcz2rw01a9hkzb9jckvy6i	39	D	2026-05-21 10:39:59.694	2026-05-21 10:39:59.694
cmpfd02q901c7hkzbadwjalhc	cmpfcz2rw01a9hkzb9jckvy6i	40	E	2026-05-21 10:39:59.694	2026-05-21 10:39:59.694
\.


--
-- Data for Name: Transaction; Type: TABLE DATA; Schema: public; Owner: sinavsistemi_admin
--

COPY public."Transaction" (id, "userId", amount, reason, "groupId", "examId", "createdAt", "institutionId") FROM stdin;
cmold5dfu002fhklsm5myg6k7	cmoc4qiu3000csufo75td3z2o	200	GROUP_JOIN	cmold59og002ehklssap2p8ik	\N	2026-04-30 10:51:01.578	\N
cmp1dzugu0004hkkn44m5dv39	cmp1dlkuw0000hkknfm3vhk2s	2500	GROUP_JOIN	cmp1dxlwe0003hkkng4uhejav	\N	2026-05-11 15:59:02.143	\N
cmp1e5hpv000ahkknfi3ts7hx	cmp1dlkuw0000hkknfm3vhk2s	5000	GROUP_JOIN	cmp1e49n30009hkkn6m32d52i	\N	2026-05-11 16:03:25.555	\N
cmqaie50e0002hkxyig2wyfeq	cmoc4qiu3000csufo75td3z2o	2500	GROUP_JOIN	cmp1dxlwe0003hkkng4uhejav	\N	2026-06-12 05:51:45.375	\N
\.


--
-- Data for Name: User; Type: TABLE DATA; Schema: public; Owner: sinavsistemi_admin
--

COPY public."User" (id, email, password, role, name, "createdAt", "updatedAt", "isActive", phone, "institutionId") FROM stdin;
cmoc1npc70000su98ftbzcgyq	info@on7yazilim.com	on7Admin17!	SUPERADMIN	Super Admin	2026-04-23 22:19:25.832	2026-04-23 22:19:25.832	t	\N	\N
cmoc4l0ya0000sufoei31630p	4takademiankara@gmail.com	4tAdmin.!	ADMIN	4T Akademi	2026-04-23 23:41:19.758	2026-04-23 23:41:19.758	t	05555555555	\N
cmoc4qiu3000csufo75td3z2o	test@test.com	123456	STUDENT	Testogr	2026-04-23 23:45:36.207	2026-04-30 10:50:03.603	t	\N	\N
cmp1dnf030001hkknu20kzwmo	asistan@on7yazilim.com	159357	ASISTAN	asistan test	2026-05-11 15:49:22.179	2026-05-11 15:49:22.179	t	08886548547	\N
cmp44zrbj0023hk44ocazd1vg	kalenderemine@yandex.com	5456699323	STUDENT	MELEK KALENDER	2026-05-13 14:10:20.043	2026-05-13 14:10:20.043	t	5456699323	\N
cmp1do4c00002hkknxwyxjv21	editor@on7yazilim.com	159357	EDITOR	editör test	2026-05-11 15:49:55.055	2026-05-11 15:53:44.472	t	06665489215	\N
cmp1py7yw0004hkplvwhdgt3u	r.akincikk@gmail.com	123456	ADMIN	Rüstem kurumu	2026-05-11 21:33:41.72	2026-05-11 21:33:41.72	t	\N	cmp1py7ys0002hkpl7m0h92xb
cmp1rahi90001hkuni7xn2iqo	ra@gmail.com	123456	STUDENT	test	2026-05-11 22:11:13.569	2026-05-11 22:11:13.569	t	055555555555	cmp1py7ys0002hkpl7m0h92xb
cmp44zr4d0019hk44phwupkpv	oz.gizem.1491@gmail.com	5343901128	STUDENT	GİZEM ÖZ	2026-05-13 14:10:19.788	2026-05-13 14:10:19.788	t	5343901128	\N
cmp44zr5a001bhk44ahj5cxip	nuranbayar2008@gmail.com	5353013307	STUDENT	NURAN BAYAR	2026-05-13 14:10:19.822	2026-05-13 14:10:19.822	t	5353013307	\N
cmp44zr5t001dhk44vvbbvq6a	erinculutas@gmail.com	5058991605	STUDENT	HALİL ERİNÇ ULUTAŞ	2026-05-13 14:10:19.842	2026-05-13 14:10:19.842	t	5058991605	\N
cmp44zr6d001fhk44lyhs44qv	kelescansu06@gmail.com	5337090610	STUDENT	CANSU KELEŞ	2026-05-13 14:10:19.861	2026-05-13 14:10:19.861	t	5337090610	\N
cmp44zr6t001hhk44ywcyd4gi	ertu.bor@gmail.com	5312667447	STUDENT	ERTUĞRUL BORAN	2026-05-13 14:10:19.877	2026-05-13 14:10:19.877	t	5312667447	\N
cmp44zr72001jhk44euy1vdvi	gozde.uzun73@gmail.com	5363245099	STUDENT	GÖZDE UZUN	2026-05-13 14:10:19.887	2026-05-13 14:10:19.887	t	5363245099	\N
cmp44zr7c001lhk44ck0j45ix	sinan.vergul@hotmail.com	5355542775	STUDENT	SİNAN VERGÜL	2026-05-13 14:10:19.897	2026-05-13 14:10:19.897	t	5355542775	\N
cmp44zr7n001nhk44c69yip6l	cerendernek07@gmail.com	5439141441	STUDENT	CEREN DERNEK	2026-05-13 14:10:19.907	2026-05-13 14:10:19.907	t	5439141441	\N
cmp44zr80001phk44ungi6mc5	kderya326@gmail.com	5343213208	STUDENT	DERYA KARA ÖZTÜRK	2026-05-13 14:10:19.92	2026-05-13 14:10:19.92	t	5343213208	\N
cmp44zr89001rhk441fv84l3k	emrepeksen3663@gmail.com	5075866462	STUDENT	EMRE PEKŞEN	2026-05-13 14:10:19.929	2026-05-13 14:10:19.929	t	5075866462	\N
cmp44zr8j001thk44ri8t9gbx	fturan742@gmail.com	5461932607	STUDENT	FATMA ALKAN	2026-05-13 14:10:19.939	2026-05-13 14:10:19.939	t	5461932607	\N
cmp44zr93001vhk442rpw9ljm	hdemir0660@gmail.com	5453066099	STUDENT	HASAN DEMİR	2026-05-13 14:10:19.959	2026-05-13 14:10:19.959	t	5453066099	\N
cmp44zr9h001xhk44y6izdsdu	sumeyranuruysal@gmail.com	5438712657	STUDENT	SÜMEYRA NUR UYSAL	2026-05-13 14:10:19.973	2026-05-13 14:10:19.973	t	5438712657	\N
cmp44zr9x001zhk44a59wrwji	ozkan25kizil@gmail.com	5417143505	STUDENT	ÖZKAN KIZIL	2026-05-13 14:10:19.989	2026-05-13 14:10:19.989	t	5417143505	\N
cmp44zra80021hk44nt83ehy6	gozutoksinem55@gmail.com	5524905072	STUDENT	SİNEM GÖZÜTOK	2026-05-13 14:10:20	2026-05-13 14:10:20	t	5524905072	\N
cmp44zrc70025hk44blxoyc8t	ebru_22nur@hotmail.com	5541901298	STUDENT	EBRU NUR GÜLBAY	2026-05-13 14:10:20.071	2026-05-13 14:10:20.071	t	5541901298	\N
cmp44zrcr0027hk44qscf8b89	hatice.goktas@outlook.com	5315197243	STUDENT	HATİCE GÖKTAŞ	2026-05-13 14:10:20.091	2026-05-13 14:10:20.091	t	5315197243	\N
cmp44zrd50029hk44yltjw8s7	miraysusezenn@gmail.com	5070117186	STUDENT	MİRAY SU SEZEN	2026-05-13 14:10:20.105	2026-05-13 14:10:20.105	t	5070117186	\N
cmp44zrdi002bhk44j1vdb8tz	1685harun@gmail.com	5051263005	STUDENT	HARUN DEMİRHAN	2026-05-13 14:10:20.118	2026-05-13 14:10:20.118	t	5051263005	\N
cmp44zrdp002dhk44y9r7gvbo	aysenuryyurdagul@outlook.com	5065860919	STUDENT	AYŞE NUR YURDAGÜL	2026-05-13 14:10:20.126	2026-05-13 14:10:20.126	t	5065860919	\N
cmp44zrdz002fhk44vc7twq9g	ercinmine9@gmail.com	5545568634	STUDENT	MİNE ERÇİN	2026-05-13 14:10:20.135	2026-05-13 14:10:20.135	t	5545568634	\N
cmp44zre7002hhk44ae6zabs1	cibikturkay@gmail.com	5349411855	STUDENT	AHMET TÜRKAY ÇIBIK	2026-05-13 14:10:20.144	2026-05-13 14:10:20.144	t	5349411855	\N
cmp44zrek002jhk44xby0u97n	guven06zeyno@gmail.com	5362745166	STUDENT	ZEYNEP DAŞKIN	2026-05-13 14:10:20.157	2026-05-13 14:10:20.157	t	5362745166	\N
cmp44zreq002lhk44xt06cnaq	efekan.ozcelik@hotmail.com	5379436588	STUDENT	EFEKAN ÖZÇELİK	2026-05-13 14:10:20.163	2026-05-13 14:10:20.163	t	5379436588	\N
cmp44zrf1002nhk44bq6010vz	kilic.baran.tr@gmail.com	5394352817	STUDENT	BARAN KILIÇ	2026-05-13 14:10:20.173	2026-05-13 14:10:20.173	t	5394352817	\N
cmp44zrfa002phk44yoxoeefu	melikekarapicak2@gmail.com	5052180783	STUDENT	MELİKE KARAPIÇAK	2026-05-13 14:10:20.182	2026-05-13 14:10:20.182	t	5052180783	\N
cmp44zrfr002rhk44mz7zehpe	aleynaecemoztemel@icloud.com 	5541601602	STUDENT	ALEYNA ECEM ÖZDEMİR	2026-05-13 14:10:20.199	2026-05-13 14:10:20.199	t	5541601602	\N
cmp44zrg3002thk445kgzv423	buseocal0606@gmail.com	5352989927	STUDENT	BUSE ÖCAL	2026-05-13 14:10:20.211	2026-05-13 14:10:20.211	t	5352989927	\N
cmp44zrkq002vhk44aiodzp1v	mehmetemsen00@gmail.com	5527487443	STUDENT	MEHMET EMSEN	2026-05-13 14:10:20.379	2026-05-13 14:10:20.379	t	5527487443	\N
cmp44zrl9002xhk44k6mklgtt	busracamli98@gmail.com	5354255552	STUDENT	BÜŞRA ÇAMLI	2026-05-13 14:10:20.397	2026-05-13 14:10:20.397	t	5354255552	\N
cmp44zrli002zhk44fvd1ek3s	zeynepkarmaksiz@gmail.com	5336305577	STUDENT	ZEYNEP KIVILCIM PARMAKSIZ	2026-05-13 14:10:20.406	2026-05-13 14:10:20.406	t	5336305577	\N
cmp44zrlw0031hk44vb4wjkbv	fatmanurulkn@gmail.com	5418717571	STUDENT	FATMA NUR ULUKAN	2026-05-13 14:10:20.42	2026-05-13 14:10:20.42	t	5418717571	\N
cmp44zrmb0033hk446hb8qr26	alid13189@gmail.com	5332317571	STUDENT	ALİ DENİZ	2026-05-13 14:10:20.435	2026-05-13 14:10:20.435	t	5332317571	\N
cmp44zrml0035hk44fot92nrh	muhammedkarasu25@gmail.com	5514759734	STUDENT	MUHAMMED KARASU	2026-05-13 14:10:20.445	2026-05-13 14:10:20.445	t	5514759734	\N
cmp44zrmu0037hk44f9uu451d	m.bilgeatak@gmail.com	5060688371	STUDENT	MÜZEYYEN BİLGE ATAK	2026-05-13 14:10:20.454	2026-05-13 14:10:20.454	t	5060688371	\N
cmp44zrn20039hk4493ottktf	leventicoz01@gmail.com	5376290428	STUDENT	LEVENT İÇÖZ	2026-05-13 14:10:20.462	2026-05-13 14:10:20.462	t	5376290428	\N
cmp44zrnf003bhk44j4d0xwzq	rmysaks891@icloud.com	5532287835	STUDENT	RÜMEYSA AK 	2026-05-13 14:10:20.475	2026-05-13 14:10:20.475	t	5532287835	\N
cmp44zrns003dhk443u14q28q	hilalylcnn@gmail.com	5526011398	STUDENT	HİLAL KÖŞKER	2026-05-13 14:10:20.488	2026-05-13 14:10:20.488	t	5526011398	\N
cmp44zro4003fhk44wloxsfc8	ssudeözerr1@gmail.com	5465830803	STUDENT	SUDE ÖZER	2026-05-13 14:10:20.501	2026-05-13 14:10:20.501	t	5465830803	\N
cmp44zrok003hhk44zspqml64	ilaydadurmaz7@gmail.com	5345154476	STUDENT	İLAYDA NUR DURMAZ	2026-05-13 14:10:20.516	2026-05-13 14:10:20.516	t	5345154476	\N
cmp44zrow003jhk44gukmimpv	byznrgurpinar@gmail.com	5541532080	STUDENT	BEYZANUR GÜRPINAR	2026-05-13 14:10:20.529	2026-05-13 14:10:20.529	t	5541532080	\N
cmp44zrp8003lhk4488w951zj	emrekck13@gmail.com	5419361059	STUDENT	EMRE KOÇAK	2026-05-13 14:10:20.54	2026-05-13 14:10:20.54	t	5419361059	\N
cmp455ced003ohk44csce5dhw	oskangokan433@gmail.com	5353780372	STUDENT	GÖKHAN ÖZKAN	2026-05-13 14:14:40.645	2026-05-13 14:14:40.645	t	5353780372	\N
cmp1dlkuw0000hkknfm3vhk2s	ogrenci@on7yazilim.com	123456	STUDENT	test öğrenci	2026-05-11 15:47:56.503	2026-06-12 05:47:58.836	t	05554449761	\N
cmp455cf4003qhk44muomosvq	yusufkoyuncu006@hotmail.com	5061799741	STUDENT	YUSUF KOYUNCU	2026-05-13 14:14:40.672	2026-05-13 14:14:40.672	t	5061799741	\N
cmp455cfc003shk44tgxwuw08	aleyna_0711@hotmail.com	5524366076	STUDENT	ALEYNA DENİZ	2026-05-13 14:14:40.681	2026-05-13 14:14:40.681	t	5524366076	\N
cmp455cfr003uhk44abp8evow	oykuyyldrm@gmail.com	5416965789	STUDENT	ÖYKÜ YILDIRIM	2026-05-13 14:14:40.695	2026-05-13 14:14:40.695	t	5416965789	\N
cmp455cga003whk4485tmnhwy	aleynahsfc_06@iloud.com	5387330929	STUDENT	ALEYNA HOŞAFCI	2026-05-13 14:14:40.715	2026-05-13 14:14:40.715	t	5387330929	\N
cmp455chb003yhk44nrph7mli	anildeniz998@gmail.com	5414710241	STUDENT	ANIL DENİZ	2026-05-13 14:14:40.751	2026-05-13 14:14:40.751	t	5414710241	\N
cmp455chq0042hk442eh63gnu	eminkaplan2006@gmail.com	5384484171	STUDENT	MUHAMMED EMİN KAPLAN	2026-05-13 14:14:40.767	2026-05-13 14:14:40.767	t	5384484171	\N
cmp455ci30044hk44f5xo6iuz	beyzasenay.2071@gmail.com	5549051397	STUDENT	BEYZA ŞENAY	2026-05-13 14:14:40.779	2026-05-13 14:14:40.779	t	5549051397	\N
cmp455cid0046hk445xtk87mj	oguzhanakgunn.06@gmail.com	5550090694	STUDENT	OĞUZHAN AKGÜN	2026-05-13 14:14:40.79	2026-05-13 14:14:40.79	t	5550090694	\N
cmp455cip0048hk44gff8wtpy	1elifsel@gmail.com	5426090510	STUDENT	ELİF ŞULE KARABIYIK	2026-05-13 14:14:40.801	2026-05-13 14:14:40.801	t	5426090510	\N
cmp455ciy004ahk44av54c33c	tugcecankaradag@gmail.com	5327460093	STUDENT	TUĞÇE KARADAĞ	2026-05-13 14:14:40.81	2026-05-13 14:14:40.81	t	5327460093	\N
cmp455cjd004chk446f866ec5	kadir0akonak@gmail.com	5339782004	STUDENT	ABDULKADİR KONAK	2026-05-13 14:14:40.825	2026-05-13 14:14:40.825	t	5339782004	\N
cmp455cjm004ehk44z4avsstp	silasungur21@gmail.com	5447364309	STUDENT	SILA SUNGUR	2026-05-13 14:14:40.834	2026-05-13 14:14:40.834	t	5447364309	\N
cmp455icz004hhk449ugq3cua	yasinburakolmez@gmail.com	5426353993	STUDENT	YASİN BURAK ÖLMEZ	2026-05-13 14:14:48.372	2026-05-13 14:14:48.372	t	5426353993	\N
cmp455idl004lhk44pf7ddqer	cetineminenur3@gmail.com	5452785639	STUDENT	EMİNE NUR ÇETİN	2026-05-13 14:14:48.393	2026-05-13 14:14:48.393	t	5452785639	\N
cmp455ids004nhk4453pp7c1d	rag.ozcann@gmail.com	5419703542	STUDENT	RAGIP ÖZCAN 	2026-05-13 14:14:48.401	2026-05-13 14:14:48.401	t	5419703542	\N
cmp455ie3004phk44bw4bzxtm	yusufurkanaktas@gmail.com	5457269215	STUDENT	YUSUF FURKAN AKTAŞ	2026-05-13 14:14:48.411	2026-05-13 14:14:48.411	t	5457269215	\N
cmp455iee004rhk44twdqi5ny	smg_1998@icloud.com	5550167427	STUDENT	SİMGE KILIÇ	2026-05-13 14:14:48.422	2026-05-13 14:14:48.422	t	5550167427	\N
cmp455ieq004thk448vvhx4qc	aleynabayram3806@gmail.com	5413769905	STUDENT	ALEYNA BAYRAM	2026-05-13 14:14:48.434	2026-05-13 14:14:48.434	t	5413769905	\N
cmp455iey004vhk443uymsxx1	keskinersin07105@gmail.com	5376103641	STUDENT	ERSİN KESKİN	2026-05-13 14:14:48.442	2026-05-13 14:14:48.442	t	5376103641	\N
cmp455if7004xhk44306s6k2h	tugceguven1994@gmail.com	5073607838	STUDENT	TUĞÇE KIRIKCI	2026-05-13 14:14:48.451	2026-05-13 14:14:48.451	t	5073607838	\N
cmp455ifk004zhk44s9alr4f0	sg.selngvenc@gmail.com	5376125956	STUDENT	SELİN ÖZTÜRK	2026-05-13 14:14:48.465	2026-05-13 14:14:48.465	t	5376125956	\N
cmp455ift0051hk445p3xoy6h	gozdesahiner4@gmail.com	5053662296	STUDENT	GÖZDE BOZKURT	2026-05-13 14:14:48.474	2026-05-13 14:14:48.474	t	5053662296	\N
cmp455ig20053hk44k9wxf531	duymazmerve46@gmail.com	5342609772	STUDENT	MERVE DUYMAZ	2026-05-13 14:14:48.483	2026-05-13 14:14:48.483	t	5342609772	\N
cmp455igd0055hk446m8i9kst	ozcanmusttafa@gmail.com	5419158399	STUDENT	MUSTAFA ÖZCAN	2026-05-13 14:14:48.493	2026-05-13 14:14:48.493	t	5419158399	\N
cmp455igz0057hk44cltzi3f0	ozanfarukoglu@gmail.com	5073388944	STUDENT	OZAN FARUKOĞLU	2026-05-13 14:14:48.515	2026-05-13 14:14:48.515	t	5073388944	\N
cmp455ih70059hk44d64fv786	akif4karaoglu@gmail.com	5358754733	STUDENT	MEHMET AKİF KARAOĞLU	2026-05-13 14:14:48.523	2026-05-13 14:14:48.523	t	5358754733	\N
cmp455ihi005bhk44qr5ms59y	kivanckarakas6@gmail.com	5302201253	STUDENT	KIVANÇ KARAKAŞ	2026-05-13 14:14:48.535	2026-05-13 14:14:48.535	t	5302201253	\N
cmp455ihs005dhk44fd2kst0m	tawar26@hotmail.com	5075482691	STUDENT	TARIK DEMİREL	2026-05-13 14:14:48.543	2026-05-13 14:14:48.543	t	5075482691	\N
cmp455ii5005fhk44bec8axjh	nazlikayakn@gmail.com	5071502979	STUDENT	NAZLI KAYA	2026-05-13 14:14:48.557	2026-05-13 14:14:48.557	t	5071502979	\N
cmp455iid005hhk44vc983fnn	yusufkolasali614@gmail.com	5537735454	STUDENT	YUSUF KOLAŞALI	2026-05-13 14:14:48.564	2026-05-13 14:14:48.564	t	5537735454	\N
cmp455iim005jhk44ycu0hqia	karatayinc@gmail.com	5455821869	STUDENT	ABDULSELAM KARATAY	2026-05-13 14:14:48.574	2026-05-13 14:14:48.574	t	5455821869	\N
cmp455iix005lhk4432qi94wv	bldemirhan19@gmail.com	5432881923	STUDENT	BETÜL DEMİRHAN	2026-05-13 14:14:48.585	2026-05-13 14:14:48.585	t	5432881923	\N
cmp455ij7005nhk446bll5e3d	kardelenkeser0@gmail.com	5366374126	STUDENT	KARDELEN KESER	2026-05-13 14:14:48.596	2026-05-13 14:14:48.596	t	5366374126	\N
cmp455iji005phk445x421glf	ozgekeyfli@gmail.com	5073000319	STUDENT	ÖZGE KEYİFLİ	2026-05-13 14:14:48.606	2026-05-13 14:14:48.606	t	5073000319	\N
cmp455ijy005rhk44p84tg8h7	TahaMetin66@gmail.com	5444076608	STUDENT	TAHA HALİT METİN	2026-05-13 14:14:48.622	2026-05-13 14:14:48.622	t	5444076608	\N
cmp455ik8005thk4483cudk8s	rabiaylcnkya3@gmail.com	5427113277	STUDENT	RABİA YALÇINKAYA	2026-05-13 14:14:48.632	2026-05-13 14:14:48.632	t	5427113277	\N
cmp455ike005vhk44syyhn57o	fulyacavdar18@gmail.com	5078824856	STUDENT	FULYA ÇAVDAR	2026-05-13 14:14:48.639	2026-05-13 14:14:48.639	t	5078824856	\N
cmp455ikn005xhk446rhukaux	mervesunat@hotmail.com	5054136329	STUDENT	MERVE AKYOL	2026-05-13 14:14:48.647	2026-05-13 14:14:48.647	t	5054136329	\N
cmp455il0005zhk4413b3ab2n	petekozlemdonmez@gmail.com	5368716776	STUDENT	PETEK ÖZLEM DÖNMEZ	2026-05-13 14:14:48.66	2026-05-13 14:14:48.66	t	5368716776	\N
cmp455ilb0061hk4488k8ti9v	mazhar.unver06@gmail.com	5353235516	STUDENT	MAZHAR ÜNVER	2026-05-13 14:14:48.671	2026-05-13 14:14:48.671	t	5353235516	\N
cmp455ilm0063hk44j84f17dx	binnuryazıcioglu@gmail.com	5394371005	STUDENT	BİNNUR MAHMUTYAZICIOĞLU	2026-05-13 14:14:48.682	2026-05-13 14:14:48.682	t	5394371005	\N
cmp455u4e0066hk44gpptpwde	nurbengisudemir01@gmail.com	5442677485	STUDENT	NUR BENGÜSU DEMİR	2026-05-13 14:15:03.615	2026-05-13 14:15:03.615	t	5442677485	\N
cmp455u4x0068hk441ak1bmv3	cerenkaralick@gmail.com	5516313674	STUDENT	CEREN KARALİ	2026-05-13 14:15:03.633	2026-05-13 14:15:03.633	t	5516313674	\N
cmp455u5a006ahk44ss4yzf1n	glrekrbcr9606@gmail.com	5422611715	STUDENT	GÜLER EKERBİÇER	2026-05-13 14:15:03.647	2026-05-13 14:15:03.647	t	5422611715	\N
cmp455u5l006chk44h4jay6ur	mertkelesoglu42@gmail.com	5303830842	STUDENT	MERT KELEŞOĞLU	2026-05-13 14:15:03.657	2026-05-13 14:15:03.657	t	5303830842	\N
cmp455u5w006ehk448tm48uol	tugce6395@gmail.com	5379985702	STUDENT	TUĞÇE ŞEN	2026-05-13 14:15:03.668	2026-05-13 14:15:03.668	t	5379985702	\N
cmp455u69006ghk44bcv12xan	mugebuketyilmaz@gmail.com	5543459408	STUDENT	MÜGE BUKET YILMAZ	2026-05-13 14:15:03.681	2026-05-13 14:15:03.681	t	5543459408	\N
cmp455u6i006ihk441c6kdpw3	sanaltugba.06@gmail.com	5396590626	STUDENT	TUĞBA ŞANAL	2026-05-13 14:15:03.691	2026-05-13 14:15:03.691	t	5396590626	\N
cmp455u6t006khk44o9r01jaa	ekinkaraoglu@gmail.com	5071610400	STUDENT	EKİN KUTADGU KARAOĞLU	2026-05-13 14:15:03.702	2026-05-13 14:15:03.702	t	5071610400	\N
cmp455u71006mhk4453djmd5n	nazlialtun.11@outlook.com	5303042411	STUDENT	NAZLICAN ALTUN	2026-05-13 14:15:03.709	2026-05-13 14:15:03.709	t	5303042411	\N
cmp455chi0040hk442ski3jjz	rcpkplnn@gmail.com	5386038050	STUDENT	RECEP KAPLAN	2026-05-13 14:14:40.758	2026-06-03 10:08:58.963	t	5386038050	\N
cmp455u7h006ohk44w8n2hu9w	serife.nazli2@gmail.com	5071716845	STUDENT	ŞERİFE NAZLI AÇIKALIN	2026-05-13 14:15:03.725	2026-05-13 14:15:03.725	t	5071716845	\N
cmp455u7w006qhk44jell2pqf	yagmurbeyazitoglu@gmail.com	5411050648	STUDENT	YAĞMUR BEYAZİTOĞLU	2026-05-13 14:15:03.74	2026-05-13 14:15:03.74	t	5411050648	\N
cmp455u88006shk44ce5bbb6s	melike.blks@gmail.com	5075973447	STUDENT	MELİKE ÇELEBİ	2026-05-13 14:15:03.752	2026-05-13 14:15:03.752	t	5075973447	\N
cmp455u8f006uhk44o5kjcxpq	ikaganyahsi@gmail.com	5331667532	STUDENT	İBRAHİM KAĞAN YAHŞİ	2026-05-13 14:15:03.759	2026-05-13 14:15:03.759	t	5331667532	\N
cmp455u8p006whk44ozm51klj	icly@outlook.com	5333980625	STUDENT	İCLAL NAZLI ATALAY	2026-05-13 14:15:03.769	2026-05-13 14:15:03.769	t	5333980625	\N
cmp455u90006yhk44yqi6yg9f	ipekbayraktar69@gmail.com	5433806169	STUDENT	İPEK BAYRAKTAR DEGE	2026-05-13 14:15:03.781	2026-05-13 14:15:03.781	t	5433806169	\N
cmp455u9f0070hk44hxenb0jf	fatmanurdemirkiran3@gmail.com	5444968832	STUDENT	FATMA DEMİRKIRAN	2026-05-13 14:15:03.795	2026-05-13 14:15:03.795	t	5444968832	\N
cmp455u9m0072hk44g0dgy9pj	zeynepzisan02@icloud.com	5523473331	STUDENT	ZEYNEP ZİŞAN OKKAN	2026-05-13 14:15:03.802	2026-05-13 14:15:03.802	t	5523473331	\N
cmp455u9z0074hk44xyqwjo06	munevvernurodabasi@gmail.com	5315099720	STUDENT	MÜNEVVER ODABAŞI	2026-05-13 14:15:03.815	2026-05-13 14:15:03.815	t	5315099720	\N
cmp455ua50076hk44vuiu2p74	beyza.topcu.96@gmail.com	5372690179	STUDENT	BEYZA TOPÇU	2026-05-13 14:15:03.821	2026-05-13 14:15:03.821	t	5372690179	\N
cmp455ub1007chk440wvoccju	glkalinsaz06@gmail.com	5386116254	STUDENT	GİZEM KALINSAZLIOĞLU	2026-05-13 14:15:03.853	2026-05-13 14:15:03.853	t	5386116254	\N
cmp455uba007ehk44uhw7tvjk	aydemirr.oznur@outlook.com	5413474845	STUDENT	ÖZGE ÇELİK	2026-05-13 14:15:03.862	2026-05-13 14:15:03.862	t	5413474845	\N
cmp455ubj007ghk44xg1kdbn5	mfkeles44@gmail.com	5551987250	STUDENT	MEHMET FATİH KELEŞ	2026-05-13 14:15:03.872	2026-05-13 14:15:03.872	t	5551987250	\N
cmp455ubv007ihk44mzhp1oah	ymrplttt@gmail.com	5056672989	STUDENT	YAĞMUR POLAT	2026-05-13 14:15:03.883	2026-05-13 14:15:03.883	t	5056672989	\N
cmp455uc4007khk44tr4bgi7c	gozdekkaraagac@gmail.com	5424775548	STUDENT	GÖZDE NUR KARAAĞAÇ	2026-05-13 14:15:03.893	2026-05-13 14:15:03.893	t	5424775548	\N
cmp455ucl007mhk4447lw5dnq	elifaleynaerol@gmail.com	5349786904	STUDENT	ELİF ALEYNA EROL	2026-05-13 14:15:03.909	2026-05-13 14:15:03.909	t	5349786904	\N
cmp455ucx007ohk44850l1m1f	kbdoganlar@gmail.com	5327071732	STUDENT	HATİCE KÜBRA DOĞANLAR	2026-05-13 14:15:03.921	2026-05-13 14:15:03.921	t	5327071732	\N
cmp455ud8007qhk44jcy4cpg2	erengoku33@gmail.com	5379941977	STUDENT	EREN GÖKÜ	2026-05-13 14:15:03.932	2026-05-13 14:15:03.932	t	5379941977	\N
cmp455udg007shk44eoan26jn	aliseptid@gmail.com	5058293423	STUDENT	ALİ SEPTİ DENİZ	2026-05-13 14:15:03.94	2026-05-13 14:15:03.94	t	5058293423	\N
cmp455udp007uhk44b3rwyag3	aybenizsirin8@gmail.com	5350580740	STUDENT	AYBENİZ ŞİRİN	2026-05-13 14:15:03.95	2026-05-13 14:15:03.95	t	5350580740	\N
cmp455ue0007whk44icwrx0u5	aslihantok98@gmail.com	5343255466	STUDENT	ASLIHAN TOK	2026-05-13 14:15:03.961	2026-05-13 14:15:03.961	t	5343255466	\N
cmp455ued007yhk442ma13tco	harunturgut07@icloud.com	5347344090	STUDENT	HARUN TURGUT	2026-05-13 14:15:03.973	2026-05-13 14:15:03.973	t	5347344090	\N
cmp455uem0080hk44vfeq6zmb	agircan.mine@gmail.com	5304996418	STUDENT	MİNE AGIRCAN	2026-05-13 14:15:03.983	2026-05-13 14:15:03.983	t	5304996418	\N
cmp455uey0082hk4411pzqpfk	mehmetcanfidanoglu@gmail.com	5077494232	STUDENT	MEHMET CAN FİDANOĞLU	2026-05-13 14:15:03.995	2026-05-13 14:15:03.995	t	5077494232	\N
cmp455uf80084hk445e234com	aleynabozkuurt@hotmail.com	5316984649	STUDENT	ALEYNA YÜCEDAĞ	2026-05-13 14:15:04.005	2026-05-13 14:15:04.005	t	5316984649	\N
cmp455uae0078hk44vp3tobpz	sara.ozdem@gmail.com	5364489552	STUDENT	SARA ÖZDEM	2026-05-13 14:15:03.831	2026-05-13 14:15:03.831	t	5364489552	\N
cmp455uaq007ahk44dy49k063	yeliz.akaydın@gmail.com	5075671874	STUDENT	YELİZ KURŞUN	2026-05-13 14:15:03.842	2026-05-13 14:15:03.842	t	5075671874	\N
cmp455ufo0086hk44c6a72bz0	berkaypolatt10@gmail.com	5512530258	STUDENT	BERKAY POLAT	2026-05-13 14:15:04.021	2026-05-13 14:15:04.021	t	5512530258	\N
cmp455ufw0088hk44qacp6ldt	serpilaltintop@gmail.com	5437129729	STUDENT	SERPİL ALTINTOP	2026-05-13 14:15:04.028	2026-05-13 14:15:04.028	t	5437129729	\N
cmp455ug8008ahk44u0vsz5jn	ecem11e@hotmail.com	5303493364	STUDENT	ECE ASLAN	2026-05-13 14:15:04.04	2026-05-13 14:15:04.04	t	5303493364	\N
cmp455ugg008chk44c3wg8nk7	ask.mf.96@gmaill.com	5060317864	STUDENT	ZEYNEP ULU	2026-05-13 14:15:04.048	2026-05-13 14:15:04.048	t	5060317864	\N
cmp4569hu008fhk44ak18dply	yusufkocak.engineer@gmail.com	5510474122	STUDENT	YUSUF KOÇAK	2026-05-13 14:15:23.536	2026-05-13 14:15:23.536	t	5510474122	\N
cmp4569i6008hhk447ylxsjl0	sumeyratas2525@hotmail.com	5452701128	STUDENT	GAMZE TAŞ	2026-05-13 14:15:23.551	2026-05-13 14:15:23.551	t	5452701128	\N
cmp4569ie008jhk44olhex53y	ss_mehmet_1907@hotmail.com	5415589520	STUDENT	MEHMET ARSLAN	2026-05-13 14:15:23.559	2026-05-13 14:15:23.559	t	5415589520	\N
cmp4569ip008lhk440wz7d7jq	aysenurunsal906@gmail.com	5072084282	STUDENT	AYŞE NUR ÜNSAL	2026-05-13 14:15:23.568	2026-05-13 14:15:23.568	t	5072084282	\N
cmp4569j1008nhk44r5iqxnf5	aysesilagursen1@gmail.com	5393496260	STUDENT	AYŞE SILA GÜRŞEN	2026-05-13 14:15:23.581	2026-05-13 14:15:23.581	t	5393496260	\N
cmp4569ja008phk44n9vzi05x	tsdln@gmail.com	5448691956	STUDENT	MELİS DAŞDELEN	2026-05-13 14:15:23.59	2026-05-13 14:15:23.59	t	5448691956	\N
cmp4569jj008rhk44yeogph9n	tyfnydn@hotmail.com	5442844514	STUDENT	TAYFUN AYDIN	2026-05-13 14:15:23.6	2026-05-13 14:15:23.6	t	5442844514	\N
cmp4569jt008thk44r29k8ls2	ibo.tetik05@gmail.com	5059724326	STUDENT	İBRAHİM TETİK	2026-05-13 14:15:23.609	2026-05-13 14:15:23.609	t	5059724326	\N
cmp4569k6008vhk44jgsxa9i3	av.tugcebagcii@gmail.com	5541295002	STUDENT	TUĞÇE BAĞCI	2026-05-13 14:15:23.623	2026-05-13 14:15:23.623	t	5541295002	\N
cmp4569kh008xhk44iq6xgc7v	selennrgs@icloud.com	5528182088	STUDENT	SELEN NARGİS	2026-05-13 14:15:23.633	2026-05-13 14:15:23.633	t	5528182088	\N
cmp4569kq008zhk44lu3ixhbd	ledunkamiloglu@gmail.com	5438711783	STUDENT	LEDÜN KAMİLOĞLU	2026-05-13 14:15:23.643	2026-05-13 14:15:23.643	t	5438711783	\N
cmp4569l50091hk44gx8bf56e	salihaslann672@gmail.com	5386062740	STUDENT	SALİH ASLAN	2026-05-13 14:15:23.657	2026-05-13 14:15:23.657	t	5386062740	\N
cmp4569lf0093hk4487tx2s3z	elifnur07700@gmail.com	5550079801	STUDENT	ELİF NUR KEMENÇE	2026-05-13 14:15:23.667	2026-05-13 14:15:23.667	t	5550079801	\N
cmp4569ln0095hk44mi185hty	Talhaipek63@gmail.com	5413348745	STUDENT	TALHA İPEK	2026-05-13 14:15:23.675	2026-05-13 14:15:23.675	t	5413348745	\N
cmp4569lw0097hk44jd98eklr	aysenurarslanpks@gmail.com	5321723171	STUDENT	AYŞENUR ARSLAN	2026-05-13 14:15:23.684	2026-05-13 14:15:23.684	t	5321723171	\N
cmp4569m70099hk44sotsjs9o	furkanylmmz41@gmail.com	5396616719	STUDENT	FURKAN YILMAZ	2026-05-13 14:15:23.692	2026-05-13 14:15:23.692	t	5396616719	\N
cmp456g9k009chk441uvc7dgd	simseekmeltem@gmail.com	5335116398	STUDENT	MELTEM ŞİMŞEK	2026-05-13 14:15:32.312	2026-05-13 14:15:32.312	t	5335116398	\N
cmp456g9w009ehk441i7rwc90	esrafb178@gmail.com	5317824929	STUDENT	ESRA KILIÇ	2026-05-13 14:15:32.324	2026-05-13 14:15:32.324	t	5317824929	\N
cmp456ga7009ghk44bbqqmoa4	sumeyrayurdagul@gmail.com	5399897281	STUDENT	SÜMEYRA YEŞİLAY	2026-05-13 14:15:32.335	2026-05-13 14:15:32.335	t	5399897281	\N
cmp456gag009ihk44bm4lenj4	kubraklcglu06@gmail.com	5399467118	STUDENT	KÜBRA KILIÇCIOĞLU	2026-05-13 14:15:32.345	2026-05-13 14:15:32.345	t	5399467118	\N
cmp456gar009khk44luaykxio	sefanurklcprlr@gmail.com	5435925125	STUDENT	ZELİHA KILIÇPARLAR	2026-05-13 14:15:32.355	2026-05-13 14:15:32.355	t	5435925125	\N
cmp456gb2009mhk445a6r1k0i	melisaozcann@hotmail.com	5337227566	STUDENT	MELİSA ÖZCAN	2026-05-13 14:15:32.367	2026-05-13 14:15:32.367	t	5337227566	\N
cmp456gbc009ohk442mtv7sf3	selefinbaskan@gmail.com	5069063236	STUDENT	SELEFİN BAŞKAN TÜRKMEN	2026-05-13 14:15:32.376	2026-05-13 14:15:32.376	t	5069063236	\N
cmp456gbl009qhk44cq11g5eh	esradgnn02@gmail.com	5524590249	STUDENT	ESRA DOĞAN	2026-05-13 14:15:32.386	2026-05-13 14:15:32.386	t	5524590249	\N
cmp456gbw009shk44filvgrp3	tenk.seyma@gmail.com	5526612424	STUDENT	ŞEYMA NUR TENK KILIÇ 	2026-05-13 14:15:32.397	2026-05-13 14:15:32.397	t	5526612424	\N
cmp456gc2009uhk446illv0q5	furkankaya40@gmail.com	5445552605	STUDENT	FURKAN KAYA	2026-05-13 14:15:32.403	2026-05-13 14:15:32.403	t	5445552605	\N
cmp456gca009whk44nvx6a43n	karasukamer@hotmail.com	5323829135	STUDENT	KAMER DELİ	2026-05-13 14:15:32.41	2026-05-13 14:15:32.41	t	5323829135	\N
cmp456mtg009zhk445cm633g8	ahmetceliloglu7410@gmail.com	5376004392	STUDENT	ZUHAL CELİLOĞLU	2026-05-13 14:15:40.805	2026-05-13 14:15:40.805	t	5376004392	\N
cmp456mtv00a1hk442kviz47q	yasinpehhlivan@gmail.com	5313038850	STUDENT	YASİN PEHLİVAN	2026-05-13 14:15:40.819	2026-05-13 14:15:40.819	t	5313038850	\N
cmp456mu600a3hk44vnsdw6sy	ernkpln1859@gmail.com	5536049952	STUDENT	EREN KAPLAN	2026-05-13 14:15:40.83	2026-05-13 14:15:40.83	t	5536049952	\N
cmp456mup00a5hk44mfmrl17j	kubraerzurum2020@gmail.com	5078504042	STUDENT	KÜBRA ERZURUM	2026-05-13 14:15:40.85	2026-05-13 14:15:40.85	t	5078504042	\N
cmp456mv600a7hk44a9knmcfk	ferhat.ak0633@gmail.com	5521763390	STUDENT	FERHAT AK	2026-05-13 14:15:40.866	2026-05-13 14:15:40.866	t	5521763390	\N
cmp456mvf00a9hk44zd0a5yz3	yesillik-kehanet-6c@icloud.com	5067952412	STUDENT	SİBEL POLATCI	2026-05-13 14:15:40.875	2026-05-13 14:15:40.875	t	5067952412	\N
cmp456mwd00abhk44queqhbqm	bozdemir35@icloud.com	5449458767	STUDENT	AHMET BOZDEMİR	2026-05-13 14:15:40.91	2026-05-13 14:15:40.91	t	5449458767	\N
cmp456mwp00adhk44xtmr12ss	nur.leyler@gmail.com	5443970920	STUDENT	EMİNE NUR LEYLEK	2026-05-13 14:15:40.921	2026-05-13 14:15:40.921	t	5443970920	\N
cmp456mww00afhk440zs6n60z	cansuualml.358@icloud.com	5326582267	STUDENT	CANSU ALMALI	2026-05-13 14:15:40.929	2026-05-13 14:15:40.929	t	5326582267	\N
cmp456mxa00ahhk44978z94ud	aycakivrak2@gmail.com	5462374150	STUDENT	AYÇA KIVRAK	2026-05-13 14:15:40.943	2026-05-13 14:15:40.943	t	5462374150	\N
cmp456mxh00ajhk44mywkaafq	k.altinnokk@gmail.com	5419053206	STUDENT	FURKAN KEMAL ALTINOK	2026-05-13 14:15:40.949	2026-05-13 14:15:40.949	t	5419053206	\N
cmp456mxr00alhk44ws9w7mxg	altinordubeyza@gmail.com	5314357615	STUDENT	BEYZA AKDOĞAN	2026-05-13 14:15:40.96	2026-05-13 14:15:40.96	t	5314357615	\N
cmp456my300anhk44eg31qkga	ozgegorenli@hotmail.com	5423537323	STUDENT	ÖZGE ÇAKIRBAL	2026-05-13 14:15:40.971	2026-05-13 14:15:40.971	t	5423537323	\N
cmp456myi00aphk44iw8w81qp	huseyinnaksuu@icloud.com	5442158016	STUDENT	ESRA AKSU	2026-05-13 14:15:40.986	2026-05-13 14:15:40.986	t	5442158016	\N
cmp456mz700arhk44y4d35nbe	balverenhavva@gmail.com	5308922152	STUDENT	HAVVA BALVEREN	2026-05-13 14:15:41.011	2026-05-13 14:15:41.011	t	5308922152	\N
cmp456mzi00athk44ttv1wp55	solmazbahar040@gmail.com	5529459407	STUDENT	BAHAR SOLMAZ	2026-05-13 14:15:41.022	2026-05-13 14:15:41.022	t	5529459407	\N
cmp456mzu00avhk442rvlmyur	aksabakic@gmail.com	5349780093	STUDENT	AKSA BAKİ ÇOBAN 	2026-05-13 14:15:41.035	2026-05-13 14:15:41.035	t	5349780093	\N
cmp456n0200axhk445ju2tl9p	eminekrdmr.34@gmail.com	5345903455	STUDENT	EMİNE PEKDEMİR	2026-05-13 14:15:41.042	2026-05-13 14:15:41.042	t	5345903455	\N
cmp456n0a00azhk44iqbxdtvp	abdulganibulut1@gmail.com	5425438366	STUDENT	ABDULGANİ BULUT	2026-05-13 14:15:41.05	2026-05-13 14:15:41.05	t	5425438366	\N
cmp456n0l00b1hk44iotdmc86	ersenamzn@gmail.com	5455636435	STUDENT	ERSEN LÜTFİ KAÇAR	2026-05-13 14:15:41.062	2026-05-13 14:15:41.062	t	5455636435	\N
cmp456n0u00b3hk44qxzkfden	hasanbyrm21211212@gmail.com	5525835238	STUDENT	HASAN BAYRAM	2026-05-13 14:15:41.07	2026-05-13 14:15:41.07	t	5525835238	\N
cmp456n1200b5hk449sm5u2bw	irem.mtlu@outlook.com	5318335981	STUDENT	İREM MUTLU	2026-05-13 14:15:41.079	2026-05-13 14:15:41.079	t	5318335981	\N
cmp456n1c00b7hk44ilrostb4	Buse.bicen@hotmail.com	5412925819	STUDENT	BUSE CANSEL BİÇEN	2026-05-13 14:15:41.088	2026-05-13 14:15:41.088	t	5412925819	\N
cmp456n1l00b9hk44gynenry8	damla.aksan@hotmail.com	5464547320	STUDENT	DAMLA AKSAN	2026-05-13 14:15:41.097	2026-05-13 14:15:41.097	t	5464547320	\N
cmp456u0w00bchk44ododlpvt	irem.nil.ozkan@gmail.com	5070308459	STUDENT	İREM NİL ÖZKAN	2026-05-13 14:15:50.144	2026-05-13 14:15:50.144	t	5070308459	\N
cmp456u1e00behk44iq7m9mqo	mehmettcinar@yahoo.com	5372704598	STUDENT	MEHMET ÇINAR	2026-05-13 14:15:50.163	2026-05-13 14:15:50.163	t	5372704598	\N
cmp456u2300bghk445imzmfy7	senacansali@hotmail.com 	5541301576	STUDENT	SENA ÇANŞALI TÜMER	2026-05-13 14:15:50.187	2026-05-13 14:15:50.187	t	5541301576	\N
cmp456u2h00bihk44tuletcpa	sezerpolat23@hotmail.com	5439300381	STUDENT	SEZER POLAT	2026-05-13 14:15:50.201	2026-05-13 14:15:50.201	t	5439300381	\N
cmp456u2z00bkhk441cc0hpk2	zeyneparslan953@gmail.com	5427918423	STUDENT	ZEYNEP ARSLAN	2026-05-13 14:15:50.219	2026-05-13 14:15:50.219	t	5427918423	\N
cmp456u3800bmhk44zvfodw6y	kadirozdogan1982@gmail.com	5448110042	STUDENT	EDA ÖZDOĞAN	2026-05-13 14:15:50.228	2026-05-13 14:15:50.228	t	5448110042	\N
cmp456u3o00bohk44wiwyq36a	brkzclk.26@gmail.com	5369486138	STUDENT	BURAK ÖZÇELİK	2026-05-13 14:15:50.244	2026-05-13 14:15:50.244	t	5369486138	\N
cmp456u4600bqhk44ejjm7p7h	drs1286@outlook.com	5349740130	STUDENT	MÜJGAN KOLUKISAOĞLU	2026-05-13 14:15:50.263	2026-05-13 14:15:50.263	t	5349740130	\N
cmp456zog00bthk44y04l87d0	sevvaltutkutoplutepe67@gmail.com	5354626759	STUDENT	ŞEVVAL TUTKU TOPLUTEPE	2026-05-13 14:15:57.473	2026-05-13 14:15:57.473	t	5354626759	\N
cmp456zos00bvhk44f4s3s2gl	dilerryt@gmail.com	5077068793	STUDENT	NUR DİLER YILMAZ	2026-05-13 14:15:57.484	2026-05-13 14:15:57.484	t	5077068793	\N
cmp456zp400bxhk44nzqksaxr	handettutar@gmail.com	5317483417	STUDENT	HANDE TUTAR	2026-05-13 14:15:57.496	2026-05-13 14:15:57.496	t	5317483417	\N
cmp456zpe00bzhk44hr8zwsk9	cdlar0271@gmail.com	5075522109	STUDENT	DİLARA ÇOLAK	2026-05-13 14:15:57.507	2026-05-13 14:15:57.507	t	5075522109	\N
cmp456zpo00c1hk44zqs3wyq0	nniissyy10@gmail.com	5070354130	STUDENT	NİSANUR YILMAZ	2026-05-13 14:15:57.516	2026-05-13 14:15:57.516	t	5070354130	\N
cmp456zpy00c3hk44wdcs4ev3	sutcuebru2@gmail.com	5469061314	STUDENT	EBRU SÜTÇÜ	2026-05-13 14:15:57.526	2026-05-13 14:15:57.526	t	5469061314	\N
cmp456zq700c5hk44yy136kp0	cicekirem2332@gmail.com	5539478308	STUDENT	İREM ÇİÇEK	2026-05-13 14:15:57.535	2026-05-13 14:15:57.535	t	5539478308	\N
cmp456zqh00c7hk44oyg5p7wm	ebru1gumuss@icloud.com	5346394279	STUDENT	EBRU GÜMÜŞ	2026-05-13 14:15:57.545	2026-05-13 14:15:57.545	t	5346394279	\N
cmp456zqq00c9hk44u6rfdx2l	akkus.caangul@gmail.com	5452838920	STUDENT	CANGÜL AKKUŞ	2026-05-13 14:15:57.555	2026-05-13 14:15:57.555	t	5452838920	\N
cmp456zr100cbhk44tng2rl3h	melisa.hemmo1@hotmail.com	5011474877	STUDENT	MELİSA ŞAHİN	2026-05-13 14:15:57.566	2026-05-13 14:15:57.566	t	5011474877	\N
cmp456zr700cdhk44xy0rmnmi	hrygksn@gmail.com	5382426816	STUDENT	HURİYE İNAN	2026-05-13 14:15:57.572	2026-05-13 14:15:57.572	t	5382426816	\N
cmp456zrh00cfhk44m0e6snj5	uresinesmanur3@gmail.com	5070318024	STUDENT	ESMANUR ÜRESİN	2026-05-13 14:15:57.581	2026-05-13 14:15:57.581	t	5070318024	\N
cmp456zs500chhk442fbx2flm	senyurtcansel@gmail.com	5350278728	STUDENT	CANSEL ŞENYURT	2026-05-13 14:15:57.605	2026-05-13 14:15:57.605	t	5350278728	\N
cmp456zsj00cjhk44exdphfmf	eliffaldemir00@gmail.com	5534271825	STUDENT	ELİF ALDEMİR	2026-05-13 14:15:57.619	2026-05-13 14:15:57.619	t	5534271825	\N
cmp456zsv00clhk44bls7idgo	burak.buyukakkas@gmail.com	5467923129	STUDENT	MİNE BÜYÜKAKKAŞ	2026-05-13 14:15:57.631	2026-05-13 14:15:57.631	t	5467923129	\N
cmp456zta00cnhk4455eb5s20	esra.isik1992@gmail.com	5468760109	STUDENT	ESRA ÖNAL	2026-05-13 14:15:57.646	2026-05-13 14:15:57.646	t	5468760109	\N
cmp456ztq00cphk44vngwyyms	busraakyol8007@gmail.com	5071477740	STUDENT	BÜŞRA AKYOL	2026-05-13 14:15:57.662	2026-05-13 14:15:57.662	t	5071477740	\N
cmp456zu300crhk44men5e0fa	mrl.mrve@gmail.com	5335131679	STUDENT	MERVE MERAL	2026-05-13 14:15:57.675	2026-05-13 14:15:57.675	t	5335131679	\N
cmp456zuc00cthk44lownvbih	ynmdk_ceren@hotmail.com	5418863528	STUDENT	CEREN AYBALA YANMADIK	2026-05-13 14:15:57.684	2026-05-13 14:15:57.684	t	5418863528	\N
cmp456zup00cvhk44as4mx10o	smmmemineinel@gmail.com	5385647660	STUDENT	EMİNE GÜNGÖR	2026-05-13 14:15:57.698	2026-05-13 14:15:57.698	t	5385647660	\N
cmp456zuy00cxhk44rslbb02x	nedimkiraz16@hotmail.com	5315697688	STUDENT	NEDİM KİRAZ	2026-05-13 14:15:57.707	2026-05-13 14:15:57.707	t	5315697688	\N
cmp456zv800czhk445ybxlf9p	ertugrulkrdnz05@gmail.com	5462372803	STUDENT	M.ERTUĞRUL KARADENİZ	2026-05-13 14:15:57.716	2026-05-13 14:15:57.716	t	5462372803	\N
cmp456zvg00d1hk44ohkskxiz	seyma.doser@hotmail.com	5428994637	STUDENT	ŞEYMA NUR DÖŞER	2026-05-13 14:15:57.724	2026-05-13 14:15:57.724	t	5428994637	\N
cmp4575kg00d4hk44y2zuolhr	durmusmustafa17@gmail.com	5312346440	STUDENT	MUSTAFA DURMUŞ	2026-05-13 14:16:05.104	2026-05-13 14:16:05.104	t	5312346440	\N
cmp4575ml00dihk44rbuzuly5	zeynepkn59@gmail.com	5078436890	STUDENT	ZEYNEP BAYDAR	2026-05-13 14:16:05.182	2026-05-13 14:16:05.182	t	5078436890	\N
cmp4575n000dkhk44raxfooif	esratasyurek25@gmail.com	5376103641	STUDENT	ESRA TAŞYÜREK	2026-05-13 14:16:05.196	2026-05-13 14:16:05.196	t	5376103641	\N
cmp4575nd00dmhk44hqq11dd3	samedbodur13@gmail.com	5448106042	STUDENT	SAMET BODUR	2026-05-13 14:16:05.209	2026-05-13 14:16:05.209	t	5448106042	\N
cmp4575nu00dohk445klvq16u	fatmagultemen015@gmail.com	5457246036	STUDENT	FATMA GÜLTEMEN	2026-05-13 14:16:05.226	2026-05-13 14:16:05.226	t	5457246036	\N
cmp4575o000dqhk44hmi9ny0s	bakiakbas458@gmail.com	5422548145	STUDENT	BAKİ AKBAŞ	2026-05-13 14:16:05.233	2026-05-13 14:16:05.233	t	5422548145	\N
cmp4575o700dshk440b43vqva	smnrkum@gmail.com	5511519142	STUDENT	SEMANUR KÜM	2026-05-13 14:16:05.239	2026-05-13 14:16:05.239	t	5511519142	\N
cmp4575od00duhk4417z4tlzl	serkaan.cerik@gmail.com	5394025099	STUDENT	CANSU ÇERİK	2026-05-13 14:16:05.245	2026-05-13 14:16:05.245	t	5394025099	\N
cmp4575oo00dwhk445fltt4up	tekdemirayse4@gmail.com	5318737199	STUDENT	AYŞE TEKDEMİR	2026-05-13 14:16:05.256	2026-05-13 14:16:05.256	t	5318737199	\N
cmp4575ov00dyhk44pekyow2v	ummuhan690@hotmail.com	5444823575	STUDENT	ÜMMÜHAN ÇAKIR	2026-05-13 14:16:05.263	2026-05-13 14:16:05.263	t	5444823575	\N
cmp4575p300e0hk441m6oslg0	semratnrl@gmail.com	5397261774	STUDENT	SEMRA TANIRLI	2026-05-13 14:16:05.272	2026-05-13 14:16:05.272	t	5397261774	\N
cmp4575pc00e2hk446y3o964k	cgrsnl95@gmail.com	5340722877	STUDENT	ÇAĞRI ŞENOL	2026-05-13 14:16:05.28	2026-05-13 14:16:05.28	t	5340722877	\N
cmp4575pl00e4hk443126ud3p	sebahatkonuss@gmail.com	5322538575	STUDENT	SEBAHAT KONUŞ	2026-05-13 14:16:05.29	2026-05-13 14:16:05.29	t	5322538575	\N
cmp4575q000e6hk44hr12a9q9	murattunc066@gmail.com	5539578301	STUDENT	MURAT TUNÇ	2026-05-13 14:16:05.304	2026-05-13 14:16:05.304	t	5539578301	\N
cmp4575qb00e8hk44yz1wno4s	wervegedik@gmail.com	5331201546	STUDENT	MERVE GEDİK	2026-05-13 14:16:05.315	2026-05-13 14:16:05.315	t	5331201546	\N
cmp4575qk00eahk44ta8vxcj1	byzanurkoca@gmail.com	5375431386	STUDENT	BEYZANUR KOCA	2026-05-13 14:16:05.325	2026-05-13 14:16:05.325	t	5375431386	\N
cmp4575qr00echk44vxpp6tq5	nalanarslan12@icloud.com	5431934642	STUDENT	NALAN ARSLAN	2026-05-13 14:16:05.331	2026-05-13 14:16:05.331	t	5431934642	\N
cmp4575r000eehk44gs5js3ab	cakirylmz45@gmail.com	5462276323	STUDENT	YILMAZ ÇAKIR	2026-05-13 14:16:05.341	2026-05-13 14:16:05.341	t	5462276323	\N
cmp4575ku00d6hk44lspsh181	melihgunduz45@icloud.com	5469301396	STUDENT	MELİH GÜNDÜZ	2026-05-13 14:16:05.118	2026-05-13 14:16:05.118	t	5469301396	\N
cmp4575la00d8hk44bm17551x	gudenmurat06@gmail.com	5319858449	STUDENT	MURAT GÜDEN	2026-05-13 14:16:05.134	2026-05-13 14:16:05.134	t	5319858449	\N
cmp4575lj00dahk44jyne8vhs	dalkilicesraa@gmail.com	5541108727	STUDENT	ESRA DALKILIÇ ÇELİK	2026-05-13 14:16:05.143	2026-05-13 14:16:05.143	t	5541108727	\N
cmp4575lt00dchk44w73w4cyz	ilkekocak95@gmail.com	5066054832	STUDENT	İLKE KOÇAK	2026-05-13 14:16:05.154	2026-05-13 14:16:05.154	t	5066054832	\N
cmp4575m100dehk442a5o41cc	hasanburakdemir0@gmail.com	5422425543	STUDENT	HASAN BURAK DEMİR	2026-05-13 14:16:05.162	2026-05-13 14:16:05.162	t	5422425543	\N
cmp4575md00dghk449ngm0mfp	iremmhaticee2018@gmail.com	5415362532	STUDENT	İREM UZER	2026-05-13 14:16:05.173	2026-05-13 14:16:05.173	t	5415362532	\N
cmp4575sx00eshk44lu92yuae	edaydogan1926@gmail.com	5074921792	STUDENT	EDA AYDOĞAN	2026-05-13 14:16:05.41	2026-05-13 14:16:05.41	t	5074921792	\N
cmp4575t700euhk44668u90tr	svcnakbaba@gmail.com	5354563334	STUDENT	SEVCAN AKBABA	2026-05-13 14:16:05.419	2026-05-13 14:16:05.419	t	5354563334	\N
cmp4575tj00ewhk44f86rjol8	brcdmr.1501@gmail.com	5538797852	STUDENT	BURCU DEMİR	2026-05-13 14:16:05.431	2026-05-13 14:16:05.431	t	5538797852	\N
cmp4575ts00eyhk44rqoa5r5e	nurullah_hacioglu@hotmail.com	5530127534	STUDENT	NURULLAH HACIOĞLU	2026-05-13 14:16:05.441	2026-05-13 14:16:05.441	t	5530127534	\N
cmp4575u100f0hk444fjp473j	gulakgll@gmail.com	5071336432	STUDENT	GÜL DALGIÇ	2026-05-13 14:16:05.45	2026-05-13 14:16:05.45	t	5071336432	\N
cmp4575u700f2hk44uwmtfb5i	fadimeuludagg@outlook.com	5376771999	STUDENT	FADİME ULUDAĞ	2026-05-13 14:16:05.455	2026-05-13 14:16:05.455	t	5376771999	\N
cmp4575ui00f4hk44o8xyh6qv	nuurdonmez@icloud.com	5010073077	STUDENT	NUR DÖNMEZ	2026-05-13 14:16:05.466	2026-05-13 14:16:05.466	t	5010073077	\N
cmp4575ut00f6hk44wnvnt02x	symnrakkus@gmail.com	5347201796	STUDENT	ŞEYMANUR AKKUŞ	2026-05-13 14:16:05.477	2026-05-13 14:16:05.477	t	5347201796	\N
cmp4575v000f8hk44nhk3m67v	altinkaynakbusra@gmail.com	5346293434	STUDENT	BÜŞRA ALTINKAYNAK	2026-05-13 14:16:05.484	2026-05-13 14:16:05.484	t	5346293434	\N
cmp4575ve00fahk44fo3lbrjk	furkanalbakir@outlook.com	5416641948	STUDENT	FURKAN ALBAKIR	2026-05-13 14:16:05.498	2026-05-13 14:16:05.498	t	5416641948	\N
cmp4575vo00fchk44yxdxybul	duygugrgll03@icloud.com	5414336494	STUDENT	DUYGU GARGILI	2026-05-13 14:16:05.508	2026-05-13 14:16:05.508	t	5414336494	\N
cmp4575vx00fehk447yc3x3yr	mervebilgekaya08@gmail.com	5353665416	STUDENT	MERVE BİLGE KAYA	2026-05-13 14:16:05.517	2026-05-13 14:16:05.517	t	5353665416	\N
cmp4575w400fghk44aba7ypc3	firdevsaksu246@gmail.com	5427812740	STUDENT	FİRDEVS ÖNAL	2026-05-13 14:16:05.525	2026-05-13 14:16:05.525	t	5427812740	\N
cmp4575wc00fihk44gq1e36s2	rabiss246@gmail.com	5541020068	STUDENT	RABİA ÖNER	2026-05-13 14:16:05.533	2026-05-13 14:16:05.533	t	5541020068	\N
cmp4575wo00fkhk44bb4db6ge	s.atmaca1999@icloud.com	5526286229	STUDENT	SILA ATMACA	2026-05-13 14:16:05.544	2026-05-13 14:16:05.544	t	5526286229	\N
cmp4575wx00fmhk44mvoyhnv5	bektasena7@gmail.com	5317391623	STUDENT	SENANUR BEKTAŞ	2026-05-13 14:16:05.553	2026-05-13 14:16:05.553	t	5317391623	\N
cmp4575x600fohk44dbecc296	elifsuduman@gmail.com	5442929460	STUDENT	ELİF SU DUMAN	2026-05-13 14:16:05.562	2026-05-13 14:16:05.562	t	5442929460	\N
cmp4575xf00fqhk440kvujtwf	nurnidaozdemir@gmail.com	5309481004	STUDENT	NUR NİDA ÖZDEMİR	2026-05-13 14:16:05.571	2026-05-13 14:16:05.571	t	5309481004	\N
cmp4575xn00fshk44cr5haum2	abdullahyanik241@gmail.com	5522460228	STUDENT	ABDULLAH YANIK	2026-05-13 14:16:05.579	2026-05-13 14:16:05.579	t	5522460228	\N
cmp4575xv00fuhk44nzfyvdk3	nurcantanyeli@gmail.com	5313423295	STUDENT	NURCAN TANYELİ	2026-05-13 14:16:05.588	2026-05-13 14:16:05.588	t	5313423295	\N
cmp4575y500fwhk449gupljrg	altaybsr@gmail.com	5397674273	STUDENT	BÜŞRA ALTAY	2026-05-13 14:16:05.598	2026-05-13 14:16:05.598	t	5397674273	\N
cmp4575yg00fyhk441bdf24xn	Zeeynep.8@outlook.com	5352442561	STUDENT	ZEYNEP YİĞİT	2026-05-13 14:16:05.609	2026-05-13 14:16:05.609	t	5352442561	\N
cmp4575ys00g0hk449ds932jq	fundagungormus1@gmail.com	5315627457	STUDENT	FUNDA GÜNGÖRMÜŞ	2026-05-13 14:16:05.62	2026-05-13 14:16:05.62	t	5315627457	\N
cmp4575z600g2hk443d792kld	Zehrakalay.97@gmail.com	5075150867	STUDENT	ZEHRA KALAY	2026-05-13 14:16:05.634	2026-05-13 14:16:05.634	t	5075150867	\N
cmp4575zd00g4hk44i8vwfzu1	Korayanlar128@gmail.com	5528016988	STUDENT	KORAY ANLAR	2026-05-13 14:16:05.642	2026-05-13 14:16:05.642	t	5528016988	\N
cmp4575zn00g6hk44dxgs6qdi	fuattoredi1993@gmail.com	5384767038	STUDENT	FUAT TÖREDİ	2026-05-13 14:16:05.652	2026-05-13 14:16:05.652	t	5384767038	\N
cmp4575zz00g8hk445hojf14i	sbengk@gmail.com	5386180528	STUDENT	SILA BENGÜSU ÖZTOP	2026-05-13 14:16:05.663	2026-05-13 14:16:05.663	t	5386180528	\N
cmp45760900gahk444m2wdc2v	melihamelis.0909@icloud.com	5339735136	STUDENT	MELİS KILIÇ	2026-05-13 14:16:05.674	2026-05-13 14:16:05.674	t	5339735136	\N
cmp45760k00gchk44xk7tyusb	yavuznaciye03@gmail.com	5531605582	STUDENT	NACİYE YAVUZ	2026-05-13 14:16:05.685	2026-05-13 14:16:05.685	t	5531605582	\N
cmp45760u00gehk44zxhzhj6x	leylacoban1625@gmail.com	5070518996	STUDENT	LEYLA ÇOBAN	2026-05-13 14:16:05.694	2026-05-13 14:16:05.694	t	5070518996	\N
cmp45760z00gghk44qvm2cibh	ssemanurcetinn@gmail.com	5061030318	STUDENT	SEMANUR ÇETİN	2026-05-13 14:16:05.7	2026-05-13 14:16:05.7	t	5061030318	\N
cmp45761b00gihk442lm2a97q	yahyagndz23@gmail.com	5510862839	STUDENT	YAHYA GÜNDÜZ	2026-05-13 14:16:05.711	2026-05-13 14:16:05.711	t	5510862839	\N
cmp45761j00gkhk44wnn42pgg	sinemkrblt66@gmail.com	5323484726	STUDENT	SİNEM KARABULUT	2026-05-13 14:16:05.719	2026-05-13 14:16:05.719	t	5323484726	\N
cmp45761t00gmhk44rj0xj340	birce.stkn@gmail.com	5454911455	STUDENT	BİRCE SAĞTEKİN	2026-05-13 14:16:05.729	2026-05-13 14:16:05.729	t	5454911455	\N
cmp45762400gohk444r5qlhso	atasoyvildan@hotmail.com	5536559106	STUDENT	VİLDAN ATASOY	2026-05-13 14:16:05.739	2026-05-13 14:16:05.739	t	5536559106	\N
cmp45762c00gqhk44qrzlx042	aysemakrbs@gmail.com	5375674514	STUDENT	AYSEMA KARABAŞ	2026-05-13 14:16:05.748	2026-05-13 14:16:05.748	t	5375674514	\N
cmp45762o00gshk44s73v3qtc	zeynepb4888@gmail.com	5534690021	STUDENT	ZEYNEP AYTAÇ	2026-05-13 14:16:05.761	2026-05-13 14:16:05.761	t	5534690021	\N
cmp45763400guhk44uqh24qhf	berrailaydacavdar@gmail.com	5327940090	STUDENT	BERRA İLAYDA ÇAVDAR	2026-05-13 14:16:05.776	2026-05-13 14:16:05.776	t	5327940090	\N
cmp45763d00gwhk44u7es49a8	alisin001@gmail.com	5062401920	STUDENT	ALİ TERLİKSİZ	2026-05-13 14:16:05.786	2026-05-13 14:16:05.786	t	5062401920	\N
cmp45763m00gyhk44860gk8x6	sema.peker.1905@gmail.com	5457378455	STUDENT	SEMA PEKER ÖZDAĞ	2026-05-13 14:16:05.794	2026-05-13 14:16:05.794	t	5457378455	\N
cmp45763w00h0hk44l13a67hc	halee.cakir@hotmail.com	5549165338	STUDENT	HALE ÜMÜTLÜ	2026-05-13 14:16:05.804	2026-05-13 14:16:05.804	t	5549165338	\N
cmp45764800h2hk44biejlpja	ranaakbiyik06@gmail.com	5528998032	STUDENT	RANA AKBIYIK	2026-05-13 14:16:05.816	2026-05-13 14:16:05.816	t	5528998032	\N
cmp45764i00h4hk44dkq85il9	berfum4406@gmail.com	5447676806	STUDENT	BERFUM ERNEZ	2026-05-13 14:16:05.826	2026-05-13 14:16:05.826	t	5447676806	\N
cmp45764r00h6hk442f4tcij5	bengusudedeoglu@gmail.com	5385043451	STUDENT	BENGÜSU DEDEOĞLU	2026-05-13 14:16:05.835	2026-05-13 14:16:05.835	t	5385043451	\N
cmp45764y00h8hk44x6n40rjb	mervegelen92@hotmail.com	5343109084	STUDENT	MERVE GELEN	2026-05-13 14:16:05.843	2026-05-13 14:16:05.843	t	5343109084	\N
cmp45765a00hahk44y66n9pgx	gizem821bla@gmail.com	5416081040	STUDENT	GİZEM KOCAMAN	2026-05-13 14:16:05.854	2026-05-13 14:16:05.854	t	5416081040	\N
cmp45765j00hchk44hcjri6m7	ssungurludavras@gmail.com	5469728818	STUDENT	ŞEYMA DAVRAS	2026-05-13 14:16:05.863	2026-05-13 14:16:05.863	t	5469728818	\N
cmp4575r600eghk441kuvrtag	bengitysz@icloud.com	5523452623	STUDENT	BENGİ TÜYSÜZ	2026-05-13 14:16:05.347	2026-05-13 14:16:05.347	t	5523452623	\N
cmp4575rj00eihk4485poxp57	hazalsilaa2503@gmail.com	5428283525	STUDENT	HAZAL SILA BAĞCI	2026-05-13 14:16:05.359	2026-05-13 14:16:05.359	t	5428283525	\N
cmp4575rw00ekhk44eam3a04h	edacantass@gmail.com	5413565277	STUDENT	EDA CANTAŞ	2026-05-13 14:16:05.372	2026-05-13 14:16:05.372	t	5413565277	\N
cmp4575s600emhk449vywlw8t	06ali06dilli06+ægmail.com	5444670645	STUDENT	ALİ DİLLİ	2026-05-13 14:16:05.382	2026-05-13 14:16:05.382	t	5444670645	\N
cmp4575sd00eohk44grd5tw80	erenkorun@gmail.com	5379878511	STUDENT	İSMAİL EREN KÖRÜN	2026-05-13 14:16:05.39	2026-05-13 14:16:05.39	t	5379878511	\N
cmp4575sm00eqhk448eafxf3c	sdfksknklc@hotmail.com	5465068644	STUDENT	SEDEF NUR KESKİNKILIÇ	2026-05-13 14:16:05.399	2026-05-13 14:16:05.399	t	5465068644	\N
cmp45766000hehk44cpr6ftgn	cananduygu@icloud.com	5331688402	STUDENT	CANAN DUYGU	2026-05-13 14:16:05.881	2026-05-13 14:16:05.881	t	5331688402	\N
cmp45766b00hghk44t2uueju7	mnvvrks@gmail.com	5337960998	STUDENT	MÜNEVVER KÖSE	2026-05-13 14:16:05.891	2026-05-13 14:16:05.891	t	5337960998	\N
cmp45766k00hihk44k5vxmbu8	fatmabyram44@gmail.com	5538441244	STUDENT	FATMA YAVUZ	2026-05-13 14:16:05.901	2026-05-13 14:16:05.901	t	5538441244	\N
cmp45766r00hkhk44iq0crnbw	dilaracandan007@gmail.com	5422925113	STUDENT	DİLARA CANDAN	2026-05-13 14:16:05.907	2026-05-13 14:16:05.907	t	5422925113	\N
cmp45767200hmhk445z8dxwwm	camrabia75@gmail.com	5464961046	STUDENT	RABİA ÇAM	2026-05-13 14:16:05.918	2026-05-13 14:16:05.918	t	5464961046	\N
cmp45767800hohk44aswrrab7	doguefeyy@gmail.com	5067132699	STUDENT	DOĞU EFE YEŞİLYURT	2026-05-13 14:16:05.925	2026-05-13 14:16:05.925	t	5067132699	\N
cmp45767m00hqhk442j1vytve	meltemokcu37@gmail.com	5522254359	STUDENT	MELTEM OKCU	2026-05-13 14:16:05.939	2026-05-13 14:16:05.939	t	5522254359	\N
cmp45767v00hshk44lfjs7z4j	bilge.sezer1965@gmail.com	5537621208	STUDENT	BİLGE SEZER	2026-05-13 14:16:05.948	2026-05-13 14:16:05.948	t	5537621208	\N
cmp45768h00huhk4429zvzlod	ssedanurgundogdu@gmail.com	5382752569	STUDENT	SEDANUR GÜNDOĞDU	2026-05-13 14:16:05.969	2026-05-13 14:16:05.969	t	5382752569	\N
cmp45768q00hwhk44mrz0z1le	azra.atilgann@gmail.com	5331473527	STUDENT	AZRA ATILGAN	2026-05-13 14:16:05.978	2026-05-13 14:16:05.978	t	5331473527	\N
cmp45768w00hyhk44o8o66w9x	erhanboz4129@gmail.com	5314396843	STUDENT	ERHAN BOZ	2026-05-13 14:16:05.984	2026-05-13 14:16:05.984	t	5314396843	\N
cmp45769400i0hk44k4tb5sl2	ranaecee@gmail.com	5531088465	STUDENT	RANA ECE UĞRAMAZ	2026-05-13 14:16:05.992	2026-05-13 14:16:05.992	t	5531088465	\N
cmp45769e00i2hk44o9a4sm7h	huriyesahin641@gmail.com	5010061405	STUDENT	HURİYE KARABULUT	2026-05-13 14:16:06.002	2026-05-13 14:16:06.002	t	5010061405	\N
cmp45769l00i4hk44ahmhg8ov	toluzeynep@hotmail.com	5392626506	STUDENT	ZEYNEP TOLU	2026-05-13 14:16:06.01	2026-05-13 14:16:06.01	t	5392626506	\N
cmp45769v00i6hk44cs7s576e	tolgakapan07@gmail.com	5312522947	STUDENT	MUSTAFA TOLGA KAPAN	2026-05-13 14:16:06.019	2026-05-13 14:16:06.019	t	5312522947	\N
cmp4576aa00i8hk44ewzrauaz	ktnn.tuba@gmail.com	5539071175	STUDENT	TUBA KOTAN	2026-05-13 14:16:06.034	2026-05-13 14:16:06.034	t	5539071175	\N
cmp4576ai00iahk44qhby2pld	kubra.ygurler@gmail.com	5356221760	STUDENT	KÜBRA GÜRLER	2026-05-13 14:16:06.042	2026-05-13 14:16:06.042	t	5356221760	\N
cmp4576aq00ichk442tvnbts4	cevriyeeelbir@gmail.com	5079062875	STUDENT	CEVRİYE ELBİR	2026-05-13 14:16:06.05	2026-05-13 14:16:06.05	t	5079062875	\N
cmp457wz800ifhk44rvokzoj3	betulozel98@gmail.com	5516604436	STUDENT	BETÜL ÖZEL	2026-05-13 14:16:40.628	2026-05-13 14:16:40.628	t	5516604436	\N
cmp457wzq00ihhk44l8ng56ay	ismailbatuhankocak@gmail.com	5464841030	STUDENT	İSMAİL BATUHAN KOÇAK	2026-05-13 14:16:40.646	2026-05-13 14:16:40.646	t	5464841030	\N
cmp457wzz00ijhk44enen631m	biltekinpakize50@gmail.com	5419043250	STUDENT	PAKİZE BİLTEKİN	2026-05-13 14:16:40.656	2026-05-13 14:16:40.656	t	5419043250	\N
cmp457x0b00ilhk44vbwkjmj6	frdevs3526@gmail.com	5423444602	STUDENT	FİRDEVS YURDAGÜL	2026-05-13 14:16:40.667	2026-05-13 14:16:40.667	t	5423444602	\N
cmp457x0n00inhk44a3zzb12f	kader.kmc25@icloud.com	5348730239	STUDENT	KADER KAMACI	2026-05-13 14:16:40.679	2026-05-13 14:16:40.679	t	5348730239	\N
cmp457x0u00iphk44hsojmuot	atesogludilek@gmail.com	5436320630	STUDENT	DİLEK ATEŞOĞLU BAD	2026-05-13 14:16:40.687	2026-05-13 14:16:40.687	t	5436320630	\N
cmp457x1500irhk44izfm17r7	elifkuyumcu408@gmail.com	5369072655	STUDENT	ELİF KUYUMCU	2026-05-13 14:16:40.697	2026-05-13 14:16:40.697	t	5369072655	\N
cmp457x1g00ithk44b2ad093e	smtyilmaz.272@gmail.com	5528385427	STUDENT	ABDULSAMET YILMAZ	2026-05-13 14:16:40.708	2026-05-13 14:16:40.708	t	5528385427	\N
cmp457x1r00ivhk44t6zzbj0v	musrafademir1108@gmail.com	5365588569	STUDENT	MUSTAFA DEMİR	2026-05-13 14:16:40.719	2026-05-13 14:16:40.719	t	5365588569	\N
cmp457x1z00ixhk44u7wbf0ot	tugcesemiz832@gmail.com	5366949818	STUDENT	TUĞÇE SEMİZ	2026-05-13 14:16:40.727	2026-05-13 14:16:40.727	t	5366949818	\N
cmp457x2b00izhk442i8nkn8v	okan1995demirkaynak@gmail.com	5445403317	STUDENT	OKAN DEMİRKAYNAK	2026-05-13 14:16:40.739	2026-05-13 14:16:40.739	t	5445403317	\N
cmp457x2m00j1hk44321kw4jc	betuulciinar@gmail.com	5349323611	STUDENT	BETÜL ÇINAR	2026-05-13 14:16:40.75	2026-05-13 14:16:40.75	t	5349323611	\N
cmp457x2t00j3hk44ew775hqu	mehmetbakiyaman@gmail.com	5051607465	STUDENT	MEHMET BAKİ YAMAN	2026-05-13 14:16:40.758	2026-05-13 14:16:40.758	t	5051607465	\N
cmp457x3600j5hk44b46dqtz1	simsimygt0915@gmail.com	5359425348	STUDENT	SİMGE YİĞİT	2026-05-13 14:16:40.77	2026-05-13 14:16:40.77	t	5359425348	\N
cmp457x3g00j7hk44s1ws3cr5	hakcay061@gmail.com	5453212371	STUDENT	BÜŞRA AKÇAY	2026-05-13 14:16:40.78	2026-05-13 14:16:40.78	t	5453212371	\N
cmp457x3t00j9hk44oaugxd96	alperenpolat0658@gmail.com	5534344313	STUDENT	ALPEREN POLAT	2026-05-13 14:16:40.794	2026-05-13 14:16:40.794	t	5534344313	\N
cmp457x4600jbhk44nr9qyfan	p.dilay.arslan@hotmail.com	5467304323	STUDENT	DİLAY ARSLAN	2026-05-13 14:16:40.807	2026-05-13 14:16:40.807	t	5467304323	\N
cmp457x4g00jdhk44iknjeo18	katumehmett@gmail.com	5458614311	STUDENT	MEHMET ALP	2026-05-13 14:16:40.817	2026-05-13 14:16:40.817	t	5458614311	\N
cmp457x4p00jfhk44nca1xnlu	ayanelif5561_@gmail.com	5433481755	STUDENT	ELİF AYAN	2026-05-13 14:16:40.826	2026-05-13 14:16:40.826	t	5433481755	\N
cmp457x5000jhhk441oa8cant	rabiaonal03@gmail.com	5457765432	STUDENT	RABİA ÖNAL	2026-05-13 14:16:40.837	2026-05-13 14:16:40.837	t	5457765432	\N
cmp457x5b00jjhk44q6aitfbk	kubragunyaz99@gmail.com	5398453591	STUDENT	KÜBRA GÜNYAZ AYYILDIZ	2026-05-13 14:16:40.847	2026-05-13 14:16:40.847	t	5398453591	\N
cmp457x5m00jlhk44w5309dh1	gulnur0738@gmail.com	5061773895	STUDENT	GÜLNUR SARIKAYA	2026-05-13 14:16:40.858	2026-05-13 14:16:40.858	t	5061773895	\N
cmp457x5w00jnhk447mp9h7v6	busrabilge07@gmail.com	5067991684	STUDENT	BÜŞRA BİLGE ŞENPOTUK	2026-05-13 14:16:40.868	2026-05-13 14:16:40.868	t	5067991684	\N
cmp457x6900jphk44brbj97q9	bsari1922@gmail.com	5051313149	STUDENT	BÜŞRA SARI	2026-05-13 14:16:40.881	2026-05-13 14:16:40.881	t	5051313149	\N
cmp457x6i00jrhk44n7elfdes	serifeozdemir048@gmail.com	5466907728	STUDENT	ŞERİFE ÖZDEMİR	2026-05-13 14:16:40.89	2026-05-13 14:16:40.89	t	5466907728	\N
cmp457x6s00jthk4436sjj060	emineezgia@gmail.com	5075478075	STUDENT	ONURCAN YOLCUOĞLU	2026-05-13 14:16:40.9	2026-05-13 14:16:40.9	t	5075478075	\N
cmp457x7200jvhk44jvplb8nt	aybuketurkoglu579@gmail.com	5349261275	STUDENT	AYBÜKE TÜRKOĞLU	2026-05-13 14:16:40.911	2026-05-13 14:16:40.911	t	5349261275	\N
cmp457x7c00jxhk4475e2obm0	ecesimsek9906@gmail.com	5520687332	STUDENT	ECE CANSU ŞİMŞEK	2026-05-13 14:16:40.921	2026-05-13 14:16:40.921	t	5520687332	\N
cmp457x7m00jzhk4450139c1c	habibesahing@gmail.com	5454077670	STUDENT	HABİBE ŞAHİN	2026-05-13 14:16:40.93	2026-05-13 14:16:40.93	t	5454077670	\N
cmp457x7w00k1hk44jpwb2cfa	semanur.moglu@gmail.com	5374511043	STUDENT	BEYZANUR MUSTAFAOĞLU	2026-05-13 14:16:40.94	2026-05-13 14:16:40.94	t	5374511043	\N
cmp457x8600k3hk443f8wu54a	safinaz.atalay@gmail.com	5435473745	STUDENT	SAFİNAZ ATALAY KARDEŞ	2026-05-13 14:16:40.95	2026-05-13 14:16:40.95	t	5435473745	\N
cmp457x8f00k5hk44w18egd2v	ozlemete42@gmail.com	5538520827	STUDENT	ÖZLEM FATMA ETE	2026-05-13 14:16:40.959	2026-05-13 14:16:40.959	t	5538520827	\N
cmp457x8s00k7hk448cpzvqis	sumersedeftansu@gmail.com	5426784343	STUDENT	SEDEF SÜMER	2026-05-13 14:16:40.972	2026-05-13 14:16:40.972	t	5426784343	\N
cmp457x8z00k9hk44vjas2xy1	busra.oztekin14@gmail.com	5070283516	STUDENT	BÜŞRA ÇİZMECİLER	2026-05-13 14:16:40.979	2026-05-13 14:16:40.979	t	5070283516	\N
cmp457x9900kbhk44sjyz0nl8	kadiryigit0106@gmail.com	5337840142	STUDENT	KADİR YİĞİT	2026-05-13 14:16:40.99	2026-05-13 14:16:40.99	t	5337840142	\N
cmp457x9j00kdhk44n3uo50w2	kadriyeyakut.429@gmail.com	5457877119	STUDENT	KADRİYE YAKUT	2026-05-13 14:16:40.999	2026-05-13 14:16:40.999	t	5457877119	\N
cmp457x9w00kfhk44bha6ga0a	beyzaylmaz2002@gmail.com	5079821410	STUDENT	BEYZA YILMAZ	2026-05-13 14:16:41.012	2026-05-13 14:16:41.012	t	5079821410	\N
cmp457xa500khhk44rbqil359	oguzincemain@gmail.com	5312320155	STUDENT	OĞUZ İNCE	2026-05-13 14:16:41.021	2026-05-13 14:16:41.021	t	5312320155	\N
cmp457xag00kjhk449kyupzhw	esrakulualp23@gmail.com	5063538728	STUDENT	ESRA KULUALP	2026-05-13 14:16:41.032	2026-05-13 14:16:41.032	t	5063538728	\N
cmp457xap00klhk44fjcl6c5a	1denizyagiz@gmail.com	5364431018	STUDENT	DENİZ YAĞIZ	2026-05-13 14:16:41.041	2026-05-13 14:16:41.041	t	5364431018	\N
cmp457xb100knhk44xrbxdm5n	ahmetenesyuce0@gmail.com	5452833744	STUDENT	ENES YÜCE	2026-05-13 14:16:41.053	2026-05-13 14:16:41.053	t	5452833744	\N
cmp457xb900kphk447hfqherc	betl-goren@hotmail.com	5072565227	STUDENT	BETÜL ÖZYILDIRIM	2026-05-13 14:16:41.061	2026-05-13 14:16:41.061	t	5072565227	\N
cmp457xbj00krhk44zabt9f07	elifberramasatli@gmail.com	5010931316	STUDENT	ELİF BERRA MASATLI	2026-05-13 14:16:41.071	2026-05-13 14:16:41.071	t	5010931316	\N
cmp457xbu00kthk44c0xttcy4	senaayyildiz160617@gmail.com	5348941251	STUDENT	SENA YILMAZ	2026-05-13 14:16:41.082	2026-05-13 14:16:41.082	t	5348941251	\N
cmp457xc200kvhk44tfzry3tx	salihaesmerr@gmail.com	5069514504	STUDENT	SALİHA KARAKAŞ	2026-05-13 14:16:41.091	2026-05-13 14:16:41.091	t	5069514504	\N
cmp457xcc00kxhk44tjzzzgh8	kutluhalilibrahimkutlu@gmail.com	5358756916	STUDENT	HALİL İBRAHİM KUTLU	2026-05-13 14:16:41.101	2026-05-13 14:16:41.101	t	5358756916	\N
cmp457xcj00kzhk4486l2gi1y	betulclk61@hotmail.com	5059856197	STUDENT	BETÜL ÇELİK	2026-05-13 14:16:41.107	2026-05-13 14:16:41.107	t	5059856197	\N
cmp457xcv00l1hk44m196y0yv	adiguzelismail93@gmail.com	5546148686	STUDENT	İSMAİL ADIGÜZEL	2026-05-13 14:16:41.119	2026-05-13 14:16:41.119	t	5546148686	\N
cmp457xd100l3hk445yjcw72o	mehmet_seyit_1998@hotmail.com	5434555442	STUDENT	MEHMET ALTINTAŞ	2026-05-13 14:16:41.125	2026-05-13 14:16:41.125	t	5434555442	\N
cmp457xdd00l5hk4437inixoj	esnaydogann7@gmail.com	5342499927	STUDENT	ESİN AYDOĞAN	2026-05-13 14:16:41.137	2026-05-13 14:16:41.137	t	5342499927	\N
cmp457xdp00l7hk443pgb13wp	ayferonarr162@gmail.com	5383923259	STUDENT	AYFER ONAR	2026-05-13 14:16:41.149	2026-05-13 14:16:41.149	t	5383923259	\N
cmp457xdz00l9hk44y7evwi2k	altugggzelal@gmail.com	5376792597	STUDENT	ZELAL ALTUĞ	2026-05-13 14:16:41.159	2026-05-13 14:16:41.159	t	5376792597	\N
cmp457xe900lbhk44d9y18cen	bernakync8@gmail.com	5324700282	STUDENT	BERNA KOYUNCU	2026-05-13 14:16:41.169	2026-05-13 14:16:41.169	t	5324700282	\N
cmp457xen00ldhk44k17b44uv	hanzadealbayrak@gmail.com	5535139669	STUDENT	HANZADE ALBAYRAK	2026-05-13 14:16:41.183	2026-05-13 14:16:41.183	t	5535139669	\N
cmp457xf100lfhk44ojx4pmih	gbildirici57@gmail.com	5432361640	STUDENT	GÜLŞEN BİLDİRİCİ	2026-05-13 14:16:41.197	2026-05-13 14:16:41.197	t	5432361640	\N
cmp457xfc00lhhk44rn4l0a8s	elifcelikk717@gmail.com	5414002658	STUDENT	ELİF ÇELİK	2026-05-13 14:16:41.208	2026-05-13 14:16:41.208	t	5414002658	\N
cmp457xfm00ljhk441omdtpv7	burakhansahin61@hotmail.com	5530675761	STUDENT	BURAKHAN ŞAHİN	2026-05-13 14:16:41.218	2026-05-13 14:16:41.218	t	5530675761	\N
cmp457xfv00llhk44eomve0he	yucelhurkan@gmail.com	5050018826	STUDENT	HÜRKAN YÜCEL	2026-05-13 14:16:41.227	2026-05-13 14:16:41.227	t	5050018826	\N
cmp457xg600lnhk44bkmciiee	aysenur.kertmen@gmail.com	5068657312	STUDENT	AYŞENUR KERTMEN	2026-05-13 14:16:41.238	2026-05-13 14:16:41.238	t	5068657312	\N
cmp457xgi00lphk44624f6nib	busra06607@gmail.com	5459119604	STUDENT	BÜŞRA TAN	2026-05-13 14:16:41.249	2026-05-13 14:16:41.249	t	5459119604	\N
cmp457xgu00lrhk44165oz4yl	zeynepbas03062003@gmail.com	5457443343	STUDENT	ZEYNEP BAŞ	2026-05-13 14:16:41.262	2026-05-13 14:16:41.262	t	5457443343	\N
cmp457xh600lthk44o4n3xtk7	sema66nur66@gmail.com	5425904566	STUDENT	SEMA NUR YİĞİT	2026-05-13 14:16:41.274	2026-05-13 14:16:41.274	t	5425904566	\N
cmp457xhi00lvhk44dwe6vusg	yasemintuncerr@icloud.com	5456370806	STUDENT	YASEMİN KUZU	2026-05-13 14:16:41.286	2026-05-13 14:16:41.286	t	5456370806	\N
cmp457xhq00lxhk444q7r1rzn	c.cerenulku@gmail.com	5065181401	STUDENT	FATMA CEREN ÜLKÜ KORKUSUZ	2026-05-13 14:16:41.294	2026-05-13 14:16:41.294	t	5065181401	\N
cmp457xi200lzhk44ukmjx4y8	ermelisa17@gmail.com	5424329511	STUDENT	MELİSA ER	2026-05-13 14:16:41.306	2026-05-13 14:16:41.306	t	5424329511	\N
cmp457xic00m1hk44y9llhfv5	tuzcuesmamelisa@gmail.com	5059708500	STUDENT	ESMA MELİSA TUZCU	2026-05-13 14:16:41.316	2026-05-13 14:16:41.316	t	5059708500	\N
cmp457xin00m3hk44nxv7lzjh	sumeyyebuyukcolak2001@gmail.com	5056439308	STUDENT	SÜMEYYE BÜYÜKÇOLAK	2026-05-13 14:16:41.327	2026-05-13 14:16:41.327	t	5056439308	\N
cmp457xix00m5hk44bw8fq0xo	vedataltinparmak@gmail.com	5421429967	STUDENT	ELİFE KARAMAN ALICIOĞLU	2026-05-13 14:16:41.337	2026-05-13 14:16:41.337	t	5421429967	\N
cmp457xj600m7hk448i172o2c	iremkan06@gmail.com	5317831235	STUDENT	İREM YILMAZ	2026-05-13 14:16:41.346	2026-05-13 14:16:41.346	t	5317831235	\N
cmp457xjj00m9hk44ib7ezqgk	ozannaktas@gmail.com	5461384041	STUDENT	OZAN AKTAŞ	2026-05-13 14:16:41.359	2026-05-13 14:16:41.359	t	5461384041	\N
cmp457xjs00mbhk44fowpal84	mrv.unverr@gmail.com	5056795794	STUDENT	MERVENUR ÜNVER	2026-05-13 14:16:41.369	2026-05-13 14:16:41.369	t	5056795794	\N
cmp457xk200mdhk44jewj2jgl	rsu710399@gmail.com	5551416448	STUDENT	RABİASU ÖZÇELİK	2026-05-13 14:16:41.378	2026-05-13 14:16:41.378	t	5551416448	\N
cmp457xka00mfhk44kr3zg31p	ipknzlshn@gmail.com	5312251135	STUDENT	İPEK NAZLI AKARSU	2026-05-13 14:16:41.386	2026-05-13 14:16:41.386	t	5312251135	\N
cmp457xkj00mhhk443mtbyvkf	sumeyyekeskin77@gmail.com	5314931707	STUDENT	SÜMEYYE KESKİN	2026-05-13 14:16:41.395	2026-05-13 14:16:41.395	t	5314931707	\N
cmp457xky00mjhk44kxof19kg	amineayyildiz.21@outlook.com	5535738800	STUDENT	AMİNE AYYILDIZ	2026-05-13 14:16:41.41	2026-05-13 14:16:41.41	t	5535738800	\N
cmp457xlb00mlhk44a95a9jfv	bugra52200@gmail.com	5452266653	STUDENT	BUĞRAHAN GÜLER	2026-05-13 14:16:41.424	2026-05-13 14:16:41.424	t	5452266653	\N
cmp457xlm00mnhk44wkk5tvdb	bsrmsk.40@gmail.com	5520188871	STUDENT	BÜŞRA ŞİMŞEK	2026-05-13 14:16:41.435	2026-05-13 14:16:41.435	t	5520188871	\N
cmp457xlv00mphk44ttt0zdqf	canselbayram2110@gmail.com	5535403055	STUDENT	CANSEL BAYRAM	2026-05-13 14:16:41.443	2026-05-13 14:16:41.443	t	5535403055	\N
cmp457xm500mrhk44ddqdrz37	mvkaya2341@gmail.com	5071387974	STUDENT	MEHMET VEFA KAYA	2026-05-13 14:16:41.454	2026-05-13 14:16:41.454	t	5071387974	\N
cmp457xme00mthk446kz436fy	yunus126763@gmail.com	5432373710	STUDENT	YUNUS EMRE YILMAZ	2026-05-13 14:16:41.463	2026-05-13 14:16:41.463	t	5432373710	\N
cmp457xnn00n1hk445f50zioj	nevzatengin94@gmail.com	5322775378	STUDENT	NEVZAT ENGİN	2026-05-13 14:16:41.508	2026-05-13 14:16:41.508	t	5322775378	\N
cmp457xoe00n5hk44wjd0ve10	ozlemnur1@hotmail.com	5526314730	STUDENT	ÖZLEM NUR ÖZTÜRK	2026-05-13 14:16:41.534	2026-05-13 14:16:41.534	t	5526314730	\N
cmp457xp900n7hk4483mqniqc	mhmtkardogan13@gmail.com	5330399413	STUDENT	MEHTAP KARDOĞAN	2026-05-13 14:16:41.565	2026-05-13 14:16:41.565	t	5330399413	\N
cmp457xpk00n9hk44s7zrf0or	suedababatr@gmail.com	5432932188	STUDENT	SÜEDA BABA	2026-05-13 14:16:41.577	2026-05-13 14:16:41.577	t	5432932188	\N
cmp457xpu00nbhk44ap2st0qe	kaya_omer04@hotmail.com	5550238932	STUDENT	ÖMER KAYA	2026-05-13 14:16:41.587	2026-05-13 14:16:41.587	t	5550238932	\N
cmp457xq900ndhk44bh3n1q9c	emredic@turanymm.com.tr 	5365667122	STUDENT	YUNUS EMRE DİÇ	2026-05-13 14:16:41.601	2026-05-13 14:16:41.601	t	5365667122	\N
cmp457xmq00mvhk44zhntusqt	haticecabuk96@gmail.com	5432671032	STUDENT	HATİCE KAYA	2026-05-13 14:16:41.475	2026-05-13 14:16:41.475	t	5432671032	\N
cmp457xn300mxhk44bx8yv7a4	sezgin.2047@gmail.com 	5386821851	STUDENT	SEZGİN VAROL	2026-05-13 14:16:41.487	2026-05-13 14:16:41.487	t	5386821851	\N
cmp457xnc00mzhk44mz8t0s21	zisanataman@gmail.com	5444012175	STUDENT	ZİŞAN ATAMAN ÇELİK	2026-05-13 14:16:41.496	2026-05-13 14:16:41.496	t	5444012175	\N
cmp457xnu00n3hk44n9zjoxm9	tr.furkancelik@gmail.com	5536556300	STUDENT	FURKAN ÇELİK	2026-05-13 14:16:41.514	2026-05-13 14:16:41.514	t	5536556300	\N
cmp457xui00o5hk44tukd73y2	defnegunes222@gmail.com	5558870538	STUDENT	DEFNE GÜNEŞ	2026-05-13 14:16:41.754	2026-05-13 14:16:41.754	t	5558870538	\N
cmp457xus00o7hk440e3l1mb8	hilal_38pkdmr@hotmail.com	5075847853	STUDENT	HİLAL PEKDEMİR	2026-05-13 14:16:41.764	2026-05-13 14:16:41.764	t	5075847853	\N
cmp457xv100o9hk44k0q58ia4	melda6196@gmail.com	5464453661	STUDENT	MELDA ÖZTÜRKOĞLU	2026-05-13 14:16:41.773	2026-05-13 14:16:41.773	t	5464453661	\N
cmp457xve00obhk44h0jdcy4l	busrayalli95@gmail.com	5070575239	STUDENT	BÜŞRA YALLI	2026-05-13 14:16:41.786	2026-05-13 14:16:41.786	t	5070575239	\N
cmp457xvo00odhk44r80ivvlp	bozok4001@icloud.com	5353083182	STUDENT	KÜBRA ERKÖK 	2026-05-13 14:16:41.796	2026-05-13 14:16:41.796	t	5353083182	\N
cmp457xyt00oxhk44gi8tteun	gozuyukarigokcen@gmail.com	5531187058	STUDENT	GÖKÇEN GÖZÜYUKARI	2026-05-13 14:16:41.91	2026-05-13 14:16:41.91	t	5531187058	\N
cmp4588do00p6hk44x0r4iosf	betlsabancii@gmail.com	5356246202	STUDENT	BETÜL SABANCI	2026-05-13 14:16:55.404	2026-05-13 14:16:55.404	t	5356246202	\N
cmp457xqj00nfhk44ubfvgc6o	busetoygan91@gmail.com	5538152852	STUDENT	BUSE TOYGAN	2026-05-13 14:16:41.611	2026-05-13 14:16:41.611	t	5538152852	\N
cmp457xqt00nhhk44lewfhmv3	ezelkizilgedikk@gmail.com	5063497806	STUDENT	EZEL KIZILGEDİK	2026-05-13 14:16:41.621	2026-05-13 14:16:41.621	t	5063497806	\N
cmp457xr300njhk447llnhd4x	cagla099@gmail.com	5345881609	STUDENT	ÇAĞLA AYDIN	2026-05-13 14:16:41.632	2026-05-13 14:16:41.632	t	5345881609	\N
cmp457xrd00nlhk44kpzkd4l8	buraksahin287@gmail.com	5348435084	STUDENT	BURAK ŞAHİN	2026-05-13 14:16:41.642	2026-05-13 14:16:41.642	t	5348435084	\N
cmp457xro00nnhk443t3keilk	gamzesaybakk@gmail.com	5372750970	STUDENT	GAMZE ŞAYBAK	2026-05-13 14:16:41.652	2026-05-13 14:16:41.652	t	5372750970	\N
cmp457xs800nphk44eg9nx38z	sungurmurat66@gmail.com	5393036546	STUDENT	MURAT SUNGUR	2026-05-13 14:16:41.672	2026-05-13 14:16:41.672	t	5393036546	\N
cmp457xsg00nrhk446cl3mjky	aycazlp@gmail.com	5312773929	STUDENT	AYÇA ÖZALP	2026-05-13 14:16:41.68	2026-05-13 14:16:41.68	t	5312773929	\N
cmp457xsp00nthk44d97rz9uw	oznuraltay11@hotmail.com	5524115939	STUDENT	ÖZNUR ALTAY	2026-05-13 14:16:41.689	2026-05-13 14:16:41.689	t	5524115939	\N
cmp457xsz00nvhk44c2pzqe83	sozenbeyzanur01@gmail.com	5536458618	STUDENT	BEYZANUR ARIK	2026-05-13 14:16:41.7	2026-05-13 14:16:41.7	t	5536458618	\N
cmp457xt900nxhk44k9u6mqte	aysemefaretkeser@gmail.com	5345777023	STUDENT	AYŞE MEFARET GÖKÇE	2026-05-13 14:16:41.71	2026-05-13 14:16:41.71	t	5345777023	\N
cmp457xtl00nzhk441297jkbw	dogansercan93@gmail.com	5466331545	STUDENT	SERCAN DOĞAN	2026-05-13 14:16:41.721	2026-05-13 14:16:41.721	t	5466331545	\N
cmp457xtu00o1hk44di1ec4ys	aysekilic2835@icloud.com	5013312835	STUDENT	AYŞE KILIÇ	2026-05-13 14:16:41.73	2026-05-13 14:16:41.73	t	5013312835	\N
cmp457xu900o3hk44g9kq70zz	inciiokk@gmail.com	5539459194	STUDENT	İNCİ OK	2026-05-13 14:16:41.745	2026-05-13 14:16:41.745	t	5539459194	\N
cmp457xvx00ofhk440r539hp9	sibelbozkurt6367@gmail.com	5374068030	STUDENT	SİBEL BOZKURT	2026-05-13 14:16:41.806	2026-05-13 14:16:41.806	t	5374068030	\N
cmp457xwa00ohhk448oupao7i	kotonatak@gmail.com	5393175185	STUDENT	ATAKAN KOTAN	2026-05-13 14:16:41.819	2026-05-13 14:16:41.819	t	5393175185	\N
cmp457xwm00ojhk44lkts0vo7	harununuvar00@gmail.com	5453708856	STUDENT	HARUN ÜNÜVAR	2026-05-13 14:16:41.83	2026-05-13 14:16:41.83	t	5453708856	\N
cmp457xwu00olhk44yv9xzpy0	enesturan093@gmail.com	5315913279	STUDENT	ENES TURAN	2026-05-13 14:16:41.838	2026-05-13 14:16:41.838	t	5315913279	\N
cmp457xx400onhk44eor85wxp	yildizmikail14@gmail.com	5445540646	STUDENT	MİKAİL YILDIZ	2026-05-13 14:16:41.849	2026-05-13 14:16:41.849	t	5445540646	\N
cmp457xxf00ophk444sdc74ft	t.gunoglu@hotmail.com	5385980198	STUDENT	TUĞÇE KARAZEYBEK	2026-05-13 14:16:41.859	2026-05-13 14:16:41.859	t	5385980198	\N
cmp457xxq00orhk44l1euv87j	aticih702@gmail.com	5431132410	STUDENT	HELİN ATICI	2026-05-13 14:16:41.871	2026-05-13 14:16:41.871	t	5431132410	\N
cmp457xy400othk44zyvgl2mb	dilararslan54@gmail.com	5378774828	STUDENT	DİLARA ARSLAN	2026-05-13 14:16:41.884	2026-05-13 14:16:41.884	t	5378774828	\N
cmp457xyf00ovhk44y3z0hk8l	burak01_68@hotmail.com	5327857058	STUDENT	BURAK CAVİZ	2026-05-13 14:16:41.895	2026-05-13 14:16:41.895	t	5327857058	\N
cmp4588cr00p0hk44boqdddzd	smmm.seda02@gmail.com	5455197008	STUDENT	SEDA IŞIK	2026-05-13 14:16:55.372	2026-05-13 14:16:55.372	t	5455197008	\N
cmp4588d300p2hk44k3r3w4rd	batuhandeu@gmail.com	5524013076	STUDENT	BATUHAN EROL	2026-05-13 14:16:55.384	2026-05-13 14:16:55.384	t	5524013076	\N
cmp4588de00p4hk44u90e49g7	oralbusra06@gmail.com	5078270444	STUDENT	BÜŞRA ORAL	2026-05-13 14:16:55.394	2026-05-13 14:16:55.394	t	5078270444	\N
cmp4588dz00p8hk44ubkxxc9y	zeynepcinkaya247@gmail.com	5360130712	STUDENT	ZEYNEP ÇİNKAYA	2026-05-13 14:16:55.415	2026-05-13 14:16:55.415	t	5360130712	\N
cmp4588e800pahk448s1cri1e	sumeyyeyucel286@gmail.com	5378147263	STUDENT	SÜMEYYE YÜCEL	2026-05-13 14:16:55.425	2026-05-13 14:16:55.425	t	5378147263	\N
cmp458shf00pdhk44fjxkcpbu	alyorukbusenur@gmail.com	5053578125	STUDENT	BUSE NUR ALYÖRÜK	2026-05-13 14:17:21.459	2026-05-13 14:17:21.459	t	5053578125	\N
cmp458si000pfhk440yu9he7k	mehmetakiferturk9@gmail.com	5427600745	STUDENT	MEHMET AKİF ERTÜRK	2026-05-13 14:17:21.48	2026-05-13 14:17:21.48	t	5427600745	\N
cmp458si600phhk4420x6flx1	egementatlisoz@gmail.com	5456967055	STUDENT	BERK TETLISÖZ	2026-05-13 14:17:21.486	2026-05-13 14:17:21.486	t	5456967055	\N
cmp458sig00pjhk44wfi3bghd	havvanur.dilsiz16@gmail.com	5383891304	STUDENT	HAVVA DİLSİZ	2026-05-13 14:17:21.496	2026-05-13 14:17:21.496	t	5383891304	\N
cmp458sir00plhk44ab9f79uz	sensiz-8727@hotmail.com	5369954155	STUDENT	BİRGÜL GÜLER	2026-05-13 14:17:21.507	2026-05-13 14:17:21.507	t	5369954155	\N
cmp458sj000pnhk44uh69oz1a	cakirmurat044@gmail.com	5343828420	STUDENT	MURAT ÇAKIR	2026-05-13 14:17:21.516	2026-05-13 14:17:21.516	t	5343828420	\N
cmp458sjb00pphk441cr59k4g	bertcanbolat@outlook.com	5334573895	STUDENT	BERT CANBOLAT	2026-05-13 14:17:21.527	2026-05-13 14:17:21.527	t	5334573895	\N
cmor1ahhf0015hkemtlp0dxba	esraaltay4t@gmail.com	5424817654	STUDENT	ESRA ALTAY	2026-05-04 10:05:41.763	2026-05-16 11:02:11.412	t	5424817654	\N
cmp455idb004jhk448w23gcni	melikesrtkyy@gmail.com	5419382309	STUDENT	MELİKE SERTKAYA TANRIKOL	2026-05-13 14:14:48.383	2026-05-19 15:38:49.582	t	5419382309	\N
cmpfcq6c000xhhkzbdz8k0oq1	selcukbyrktr@hotmail.com	5549212111	STUDENT	SELÇUK BAYRAKTAR	2026-05-21 10:32:17.808	2026-05-21 10:32:17.808	t	5549212111	\N
cmplb4nwo0002hkpzty5en03e	incegilerkan@gmail.com	5393750227	STUDENT	ERKAN İNCEGİL	2026-05-25 14:34:11.592	2026-05-25 14:34:11.592	t	5393750227	\N
cmplb4nxh0004hkpzask6p1mr	ozhan2111@hotmail.com	5398632195	STUDENT	BÜŞRA ÖZDİL	2026-05-25 14:34:11.622	2026-05-25 14:34:11.622	t	5398632195	\N
cmplb4nxv0006hkpzqqyc5xks	yareeeen1@outlook.com	5520077316	STUDENT	YAREN KAÇAR	2026-05-25 14:34:11.635	2026-05-25 14:34:11.635	t	5520077316	\N
cmplb4nya0008hkpzrs6biruc	ezgi.yurt1@icloud.com	5462611319	STUDENT	EZGİ ÖZER	2026-05-25 14:34:11.65	2026-05-25 14:34:11.65	t	5462611319	\N
cmplb4nyn000ahkpzh0hn0eme	ozdemirmerve343@gmail.com	5319763188	STUDENT	MERVE ÖZDEMİR	2026-05-25 14:34:11.663	2026-05-25 14:34:11.663	t	5319763188	\N
cmplb4nyz000chkpztfbcix43	zeynep.1997@outlook.com	5531675089	STUDENT	ZEYNEP UYGUR	2026-05-25 14:34:11.675	2026-05-25 14:34:11.675	t	5531675089	\N
cmplb4nzd000ehkpzvj3apbsa	yusufarda2258@gmail.com	5513901922	STUDENT	YUSUF ARDA IŞIK	2026-05-25 14:34:11.689	2026-05-25 14:34:11.689	t	5513901922	\N
cmplb4nzq000ghkpznr9eb7a5	hasan_ozk@hotmail.com	5436155238	STUDENT	HASAN ÖZKAN	2026-05-25 14:34:11.702	2026-05-25 14:34:11.702	t	5436155238	\N
cmplb4o03000ihkpzw9de6erq	esmagulkavraz49@gmail.com	5356058775	STUDENT	ESMA GÜL KAVRAZ	2026-05-25 14:34:11.714	2026-05-25 14:34:11.714	t	5356058775	\N
cmplb4o0e000khkpza3e75kv6	ilknurylmz9@icloud.com	5436771793	STUDENT	İLNUR YILMAZ	2026-05-25 14:34:11.727	2026-05-25 14:34:11.727	t	5436771793	\N
cmplb4o0q000mhkpz99u7snp0	tugceyilmaz00@hotmail.com	5078446954	STUDENT	TUĞÇE YILMAZ	2026-05-25 14:34:11.739	2026-05-25 14:34:11.739	t	5078446954	\N
cmplb4o13000ohkpzgwaftpvn	deryauzun168@gmail.com	5352833147	STUDENT	DERYA ÖZCAN	2026-05-25 14:34:11.751	2026-05-25 14:34:11.751	t	5352833147	\N
cmplb4o1e000qhkpzko9eg0jx	sedayse.demir@gmail.com	5452181932	STUDENT	SEDA AYŞE DEMİR	2026-05-25 14:34:11.762	2026-05-25 14:34:11.762	t	5452181932	\N
cmplb4o1w000shkpzxyppo68e	dalmela1201@gmail.com	5355440610	STUDENT	ELANUR DALMIŞ	2026-05-25 14:34:11.78	2026-05-25 14:34:11.78	t	5355440610	\N
cmplb4o29000uhkpzrs4am7an	doganbetul412@gmail.com	5346337915	STUDENT	BETÜL KESKİN	2026-05-25 14:34:11.793	2026-05-25 14:34:11.793	t	5346337915	\N
cmplb4o2j000whkpzl7r9y5a6	yusuf.esergun@gmail.com	5452232316	STUDENT	YUSUF ESERGÜL	2026-05-25 14:34:11.804	2026-05-25 14:34:11.804	t	5452232316	\N
cmplb4o2v000yhkpzo2kxzv0o	blodberke@gmail.com	5392437078	STUDENT	BERKE DEĞİRMENCİ	2026-05-25 14:34:11.815	2026-05-25 14:34:11.815	t	5392437078	\N
cmplb4o3d0010hkpzxmryokmc	bilgekulular@hotmail.com	5303328593	STUDENT	BİLGE KULULAR	2026-05-25 14:34:11.833	2026-05-25 14:34:11.833	t	5303328593	\N
cmplb4o3t0012hkpzagyekzxe	tugcedemiir.99@gmail.com	5360108870	STUDENT	TUĞÇE DEMİR	2026-05-25 14:34:11.849	2026-05-25 14:34:11.849	t	5360108870	\N
cmplb4o440014hkpzvidqsp6w	egilmez12@hotmail.com	5303733130	STUDENT	GİZEM EĞİLMEZ	2026-05-25 14:34:11.861	2026-05-25 14:34:11.861	t	5303733130	\N
cmplb4o4h0016hkpzv3s5wl6a	ozturkferhat86@gmail.com	5533792416	STUDENT	FERHAT ÖZTÜRK	2026-05-25 14:34:11.873	2026-05-25 14:34:11.873	t	5533792416	\N
cmplb4o4s0018hkpzf756xuzy	zgygt2805@gmail.com	5380538146	STUDENT	ÖZGE NUR YİĞİT	2026-05-25 14:34:11.885	2026-05-25 14:34:11.885	t	5380538146	\N
cmplb4o54001ahkpzmrbff3o0	senaerciyasss@gmail.com	5534486711	STUDENT	SENA ERCİYAS	2026-05-25 14:34:11.897	2026-05-25 14:34:11.897	t	5534486711	\N
cmplb4o5e001chkpzya2s9xvo	sbl.ks.43@gmail.com	5422245143	STUDENT	SİBEL KOLAY	2026-05-25 14:34:11.906	2026-05-25 14:34:11.906	t	5422245143	\N
cmplb4o5p001ehkpz4f9byzn5	yagmurkocamaz@hotmail.com	5350492419	STUDENT	YAĞMUR KOCAMAZ	2026-05-25 14:34:11.917	2026-05-25 14:34:11.917	t	5350492419	\N
cmplb4o61001ghkpz5yq53khl	aysunsandall@gmail.com	5383517757	STUDENT	AYSUN SANDAL	2026-05-25 14:34:11.93	2026-05-25 14:34:11.93	t	5383517757	\N
cmplb4o6f001ihkpzt9kpk285	karabudak_bilal@hotmail.com	5459255989	STUDENT	MUHAMMET BİLAL KARABUDAK	2026-05-25 14:34:11.944	2026-05-25 14:34:11.944	t	5459255989	\N
cmplb4o6r001khkpz20613usr	semanurtekinturk@gmail.com	5076340996	STUDENT	SEMA NUR TEKİNTÜRK	2026-05-25 14:34:11.955	2026-05-25 14:34:11.955	t	5076340996	\N
cmplb4o71001mhkpzev65ffgr	fatihbag2549@hotmail.com	5536834925	STUDENT	DERYA BAĞ	2026-05-25 14:34:11.965	2026-05-25 14:34:11.965	t	5536834925	\N
cmplb4o7e001ohkpziw18ft9q	has.elicabuk@gmail.com	5322012438	STUDENT	HASAN ELİÇABUK	2026-05-25 14:34:11.978	2026-05-25 14:34:11.978	t	5322012438	\N
cmplb4o7p001qhkpz1pvitrzj	11ceyhanbatuhan@gmail.com	5317947193	STUDENT	BATUHAN CEYLAN	2026-05-25 14:34:11.989	2026-05-25 14:34:11.989	t	5317947193	\N
cmplb4o82001shkpz7pg18pvh	eminetosun961@gmail.com	5445296225	STUDENT	EMİNE TOSUN	2026-05-25 14:34:12.002	2026-05-25 14:34:12.002	t	5445296225	\N
cmplb4o8a001uhkpz330vf17w	ynsakgl35@icloud.com	5516589598	STUDENT	YUNUS AKGÜL	2026-05-25 14:34:12.01	2026-05-25 14:34:12.01	t	5516589598	\N
cmplb4o8i001whkpzmlu0hg7i	nilaycengiz1461@gmail.com	5375768900	STUDENT	NİLAY CENGİZ	2026-05-25 14:34:12.019	2026-05-25 14:34:12.019	t	5375768900	\N
cmplb4o8u001yhkpz1i26ik3h	d.tugceparlak@gmail.com	5549392215	STUDENT	TUĞÇE TANIN	2026-05-25 14:34:12.03	2026-05-25 14:34:12.03	t	5549392215	\N
cmplb4o930020hkpzwo4pnwzx	songul_61_ozturk@hotmail.com	5453617397	STUDENT	SONGÜL ÖZTÜRK	2026-05-25 14:34:12.039	2026-05-25 14:34:12.039	t	5453617397	\N
cmplb4o9c0022hkpzvo43chiq	ilaydaofkeli@gmail.com	5379155969	STUDENT	İLAYDA ÖFKELİ	2026-05-25 14:34:12.048	2026-05-25 14:34:12.048	t	5379155969	\N
cmplb4o9l0024hkpzpia9xvl3	semih58123@gmail.com	5060281734	STUDENT	SEMİH BÖLÜKBAŞI	2026-05-25 14:34:12.058	2026-05-25 14:34:12.058	t	5060281734	\N
cmplb4o9u0026hkpzx47n6b65	emresndkc55@gmail.com	5312905168	STUDENT	EMRE SANDIKCI	2026-05-25 14:34:12.067	2026-05-25 14:34:12.067	t	5312905168	\N
cmplb4oa50028hkpzx6d7unfh	mustafayasinozaydin@gmail.com	5406564598	STUDENT	MUSTAFA YASİN ÖZAYDIN	2026-05-25 14:34:12.077	2026-05-25 14:34:12.077	t	5406564598	\N
cmplb4oae002ahkpz2cnde67b	latifeblc06@gmail.com	5400220619	STUDENT	LATİFE BALCI	2026-05-25 14:34:12.087	2026-05-25 14:34:12.087	t	5400220619	\N
cmplb4oan002chkpzjhpfzemr	mehmetefe191919@gmail.com	5074150327	STUDENT	EFE SIVACI	2026-05-25 14:34:12.096	2026-05-25 14:34:12.096	t	5074150327	\N
cmplb4oax002ehkpzpiuzbllk	batuhanuner43@icloud.com	5434346656	STUDENT	BATUHAN ÜNER	2026-05-25 14:34:12.105	2026-05-25 14:34:12.105	t	5434346656	\N
cmplb4ob7002ghkpz6mo8cigt	semanurgokcentuna@gmail.com	5355980912	STUDENT	SEMANUR GÖKÇEN TUNA	2026-05-25 14:34:12.115	2026-05-25 14:34:12.115	t	5355980912	\N
cmplb4obj002ihkpzvbmi5438	rummkarr@gmail.com	5392388674	STUDENT	RÜMEYSA KARAÇAM	2026-05-25 14:34:12.127	2026-05-25 14:34:12.127	t	5392388674	\N
cmplb4obr002khkpzpgo8nyz1	boranefe.rok@icloud.com	5395875905	STUDENT	BORAN EFE KURT	2026-05-25 14:34:12.135	2026-05-25 14:34:12.135	t	5395875905	\N
cmplb4oby002mhkpz36q6lp8e	sevdenurdemir1997@gmail.com	5312456115	STUDENT	SEVGİ NUR DEMİR	2026-05-25 14:34:12.143	2026-05-25 14:34:12.143	t	5312456115	\N
cmplb4oc5002ohkpzh9svct16	yusufk0307@gmail.com	5517152864	STUDENT	YUSUF KARAKAYA	2026-05-25 14:34:12.15	2026-05-25 14:34:12.15	t	5517152864	\N
cmplb4ocd002qhkpz37sebi9m	bozlakburcu@gmail.com	5359483797	STUDENT	HABİBE BURCU UZUN	2026-05-25 14:34:12.157	2026-05-25 14:34:12.157	t	5359483797	\N
cmplb4ocm002shkpz6kxxmnqu	heredotx@hotmail.com	5369379158	STUDENT	EBRAR DİLKİ	2026-05-25 14:34:12.166	2026-05-25 14:34:12.166	t	5369379158	\N
cmplb4oct002uhkpz6f6f3h14	merve_kzlkaya_06@icloud.com	5444697664	STUDENT	MERVENUR KIZILKAYA	2026-05-25 14:34:12.173	2026-05-25 14:34:12.173	t	5444697664	\N
cmplb4od0002whkpze09glth4	elifekindurhan@gmail.com	5372469797	STUDENT	ELİF EKİN DURHAN	2026-05-25 14:34:12.18	2026-05-25 14:34:12.18	t	5372469797	\N
cmplb4od8002yhkpzlr5a5mvq	beyzyam@gmail.com	5530880714	STUDENT	BEYZA YÜKSEL	2026-05-25 14:34:12.189	2026-05-25 14:34:12.189	t	5530880714	\N
cmplb4odi0030hkpzgg2zcf4o	merve.erdivan@gmail.com	5372765271	STUDENT	MERVE ŞERAN	2026-05-25 14:34:12.199	2026-05-25 14:34:12.199	t	5372765271	\N
cmplb4odr0032hkpz8ampg7j0	ilaydakamac@gmail.com	5071367063	STUDENT	İLAYDA KAMACI	2026-05-25 14:34:12.207	2026-05-25 14:34:12.207	t	5071367063	\N
cmplb4oe00034hkpzqhrcr5f3	busrakarakoyun@outlook.com	5415344049	STUDENT	BÜŞRA YAŞAR	2026-05-25 14:34:12.217	2026-05-25 14:34:12.217	t	5415344049	\N
cmplb4oeb0036hkpzjqqpqs7h	ataerol39@gmail.com	5060563236	STUDENT	ATA ALPTUĞ EROL	2026-05-25 14:34:12.226	2026-05-25 14:34:12.226	t	5060563236	\N
cmplb4oek0038hkpzkgbrykps	meliketzgl@icloud.com	5356906965	STUDENT	MELİKE YAREN TAZEGÜL	2026-05-25 14:34:12.236	2026-05-25 14:34:12.236	t	5356906965	\N
cmplb4oew003ahkpzh67sxn9d	onkolozlem@gmail.com	5323681749	STUDENT	ÖZLEM ÖNKOL	2026-05-25 14:34:12.248	2026-05-25 14:34:12.248	t	5323681749	\N
cmplb4of7003chkpz70ckujk2	cetinhoru1903@gmail.com	5372735415	STUDENT	RAMAZAN SADRİ ÇETİN	2026-05-25 14:34:12.259	2026-05-25 14:34:12.259	t	5372735415	\N
cmplb4ofe003ehkpzi9hb7hpx	ferruh55cep@gmail.com	542 514 5073	STUDENT	FERRUH CEP	2026-05-25 14:34:12.267	2026-05-25 14:34:12.267	t	542 514 5073	\N
cmplb4ofm003ghkpz7gddwor0	ecemakgul42@gmail.com	5455232350	STUDENT	ECEM ÖDEMİŞ	2026-05-25 14:34:12.275	2026-05-25 14:34:12.275	t	5455232350	\N
cmplb4ofy003ihkpzyvbov3yh	adaltkaraylan@gmail.com	5325476794	STUDENT	ADALET KARAYILANLI	2026-05-25 14:34:12.286	2026-05-25 14:34:12.286	t	5325476794	\N
cmplb4og8003khkpzbcgt4w58	aliiboztepe@hotmail.com	5423990867	STUDENT	HİLAL BOZTEPE	2026-05-25 14:34:12.296	2026-05-25 14:34:12.296	t	5423990867	\N
cmplb4ogh003mhkpznl363pmd	amondgruth@gmail.com	5414689807	STUDENT	YUSUF YOKUŞ	2026-05-25 14:34:12.305	2026-05-25 14:34:12.305	t	5414689807	\N
cmplb4ogq003ohkpz414ng3nk	eda.3026@gmail.com	5550381705	STUDENT	EDA ASAN	2026-05-25 14:34:12.314	2026-05-25 14:34:12.314	t	5550381705	\N
cmplb4ogz003qhkpzqx7a2pvb	nash_turan@hotmail.com	5536787152	STUDENT	TURAN KARAGÖMLEKO	2026-05-25 14:34:12.323	2026-05-25 14:34:12.323	t	5536787152	\N
cmplb4oh7003shkpz65rg19er	hilal.elyildirim@gmail.com	5351023693	STUDENT	HİLAL ERYILDIRIM	2026-05-25 14:34:12.331	2026-05-25 14:34:12.331	t	5351023693	\N
cmplb4ohg003uhkpzr373b49e	tugbaylmz43@gmail.com	5462724617	STUDENT	TUĞBA YILMAZ	2026-05-25 14:34:12.34	2026-05-25 14:34:12.34	t	5462724617	\N
cmplb4oho003whkpzup314m20	man_of_the_steel@hotmail.com	5303261025	STUDENT	MUSTAFA ARİF TAŞBAŞI	2026-05-25 14:34:12.349	2026-05-25 14:34:12.349	t	5303261025	\N
cmplb4ohw003yhkpz2rluy3ya	pinartaskan1995@gmail.com	5457134433	STUDENT	PINAR TAŞKAN	2026-05-25 14:34:12.356	2026-05-25 14:34:12.356	t	5457134433	\N
cmplb4oi40040hkpznaksnq20	sohretoksuz065@gmail.com	5434020396	STUDENT	ŞÖHRET ÖKSÜZ	2026-05-25 14:34:12.365	2026-05-25 14:34:12.365	t	5434020396	\N
cmplb4oie0042hkpz6sxibwmd	aycankaramustafa@gmail.com	5434155557	STUDENT	AYCAN KARAMUSTAFAOĞLU	2026-05-25 14:34:12.374	2026-05-25 14:34:12.374	t	5434155557	\N
cmplb4oim0044hkpzxppdhm96	akcaycaglaa@gmail.com	5372523880	STUDENT	ÇAĞLA AKÇAY	2026-05-25 14:34:12.382	2026-05-25 14:34:12.382	t	5372523880	\N
cmplb4oiz0046hkpzaz7pyqen	doru.141@gmail.com	5536717389	STUDENT	MUHAMMET DORU	2026-05-25 14:34:12.395	2026-05-25 14:34:12.395	t	5536717389	\N
cmplb4oj70048hkpzusqkvlu1	husnamemis6@gmail.com	5300759688	STUDENT	HÜSNA MEMİŞ	2026-05-25 14:34:12.404	2026-05-25 14:34:12.404	t	5300759688	\N
cmplb4ojh004ahkpzvqsn0wwv	aysarozkan@icloud.com	5439107545	STUDENT	FADİME ÖZKAN	2026-05-25 14:34:12.413	2026-05-25 14:34:12.413	t	5439107545	\N
cmplb4ojp004chkpzjdm6zb81	nurdanoncu06@gmail.com	5074088062	STUDENT	NURDAN ÖNCÜ	2026-05-25 14:34:12.422	2026-05-25 14:34:12.422	t	5074088062	\N
cmplb4ojy004ehkpz9uycbiws	elifmasatli19@hotmail.com	5436491319	STUDENT	ELİF MASATLI	2026-05-25 14:34:12.43	2026-05-25 14:34:12.43	t	5436491319	\N
cmplb4ok8004ghkpzphsas049	kubrasontur@gmail.com	5533435647	STUDENT	KÜBRA SONTUR	2026-05-25 14:34:12.44	2026-05-25 14:34:12.44	t	5533435647	\N
cmplb4okg004ihkpzccajslj9	ahdogan96@gmail.com	5464110892	STUDENT	AHMET HAKAN DOĞAN	2026-05-25 14:34:12.448	2026-05-25 14:34:12.448	t	5464110892	\N
cmplb4okp004khkpzyti08q1p	salihahanlioglu@yahoo.com.tr	5355596235	STUDENT	SALİHA HANLIOĞLU	2026-05-25 14:34:12.457	2026-05-25 14:34:12.457	t	5355596235	\N
cmplb4ol1004mhkpztxqc1m38	ali.eroglu732@gmail.com	5072074864	STUDENT	ALİ EROĞLU	2026-05-25 14:34:12.469	2026-05-25 14:34:12.469	t	5072074864	\N
cmplb4olf004ohkpzroh6d9se	av.ilaydaonder@gmail.com	5072139592	STUDENT	İLAYDA ÖNDER	2026-05-25 14:34:12.483	2026-05-25 14:34:12.483	t	5072139592	\N
cmplb4olo004qhkpzbstfsz1x	simgecakmak@gmail.com	5078582952	STUDENT	SİMGE ÇAKMAK	2026-05-25 14:34:12.492	2026-05-25 14:34:12.492	t	5078582952	\N
cmplb4om6004shkpz34gugrzt	bilalahmet2272@gmail.com	5375564713	STUDENT	BİLAL AHMET DENER	2026-05-25 14:34:12.51	2026-05-25 14:34:12.51	t	5375564713	\N
cmplb4omk004uhkpzn8qicomj	06gne1905@gmail.com	5060596363	STUDENT	GÖKTUĞ NUSRET ERDOĞAN	2026-05-25 14:34:12.524	2026-05-25 14:34:12.524	t	5060596363	\N
cmplb4omx004whkpz44t81rvo	celenceylan06@gmail.com	5325724655	STUDENT	CEYLAN ÇELEN	2026-05-25 14:34:12.537	2026-05-25 14:34:12.537	t	5325724655	\N
cmplbkfs4004yhkpzqh2qmnt6	zelihaekici06@gmail.com	5542058111	STUDENT	ZELİHA EKİCİ	2026-05-25 14:46:27.556	2026-05-25 14:46:27.556	t	5542058111	\N
cmpxr9djd0001hke6djazj2jz	ysfkabukcu7@gmail.com	5385079149	STUDENT	YUSUF KABUKÇU	2026-06-03 07:38:59.401	2026-06-03 07:38:59.401	t	5385079149	\N
cmpy7fueb01aahke6az1sdq59	gizemgurdogan24@gmail.com	5522077364	STUDENT	Zeliha gizem Gürdoğan	2026-06-03 15:11:55.041	2026-06-03 15:11:55.041	t	5522077364	\N
cmpy7fuf101achke65wkchu9i	sumeyyesoyturk09@gmail.com	5537559729	STUDENT	SÜMEYYE SOYTÜRK	2026-06-03 15:11:55.069	2026-06-03 15:11:55.069	t	5537559729	\N
cmpy7fufb01aehke62c9pie4l	berna.acar34@hotmail.com	5453546055	STUDENT	BERNA ACAR	2026-06-03 15:11:55.079	2026-06-03 15:11:55.079	t	5453546055	\N
cmpy7fufn01aghke6kygd4mux	acarsafak98@gmail.com	5548765334	STUDENT	ŞAFAK AÇAR	2026-06-03 15:11:55.091	2026-06-03 15:11:55.091	t	5548765334	\N
cmpy7fufw01aihke673zcogvy	dnmzirem@icloud.com	5530846272	STUDENT	İREM DÖNMEZ	2026-06-03 15:11:55.1	2026-06-03 15:11:55.1	t	5530846272	\N
cmpy7fug501akhke6mkojv0oh	dilekkucuk.4242@gmail.com	5459154573	STUDENT	DİLEK KÜÇÜK	2026-06-03 15:11:55.11	2026-06-03 15:11:55.11	t	5459154573	\N
cmpy7fugf01amhke6aeokbiw6	agicsinan01@gmail.com	5343919727	STUDENT	SİNAN AĞIÇ	2026-06-03 15:11:55.12	2026-06-03 15:11:55.12	t	5343919727	\N
cmpy7fugq01aohke683halslh	ceylanseda280196@gmail.com	5301659014	STUDENT	SEDA CEYLAN	2026-06-03 15:11:55.13	2026-06-03 15:11:55.13	t	5301659014	\N
cmpy7fuh101aqhke663j43nxu	ahsen_sar8@icloud.com	5382589516	STUDENT	AHSEN SARI	2026-06-03 15:11:55.141	2026-06-03 15:11:55.141	t	5382589516	\N
cmpy7fuhd01ashke67l1oh3e3	ayseoncerr@outlook.com	5439669274	STUDENT	AYŞE ÖNCER	2026-06-03 15:11:55.153	2026-06-03 15:11:55.153	t	5439669274	\N
cmpy7fuhm01auhke6zbf7424l	sametbayrak955@gmail.com	5453702257	STUDENT	BAYRAM SAMET BAYRAK	2026-06-03 15:11:55.162	2026-06-03 15:11:55.162	t	5453702257	\N
cmpy7fuhs01awhke6munzb889	elif.incedere@gmail.com	5426764677	STUDENT	ELİF İNCEDERE	2026-06-03 15:11:55.169	2026-06-03 15:11:55.169	t	5426764677	\N
cmpy7fui101ayhke68m0p9lbc	yaseminmonn@gmail.com	5375606752	STUDENT	YASEMİN MÖNÜN	2026-06-03 15:11:55.178	2026-06-03 15:11:55.178	t	5375606752	\N
cmpy7fuia01b0hke6wij9vew4	ssemercioglu@hotmail.com	5523803048	STUDENT	SÜLEYMAN SEMERCİOĞLU	2026-06-03 15:11:55.186	2026-06-03 15:11:55.186	t	5523803048	\N
cmpy7fuij01b2hke619bz5wsb	gozdesirin1993@gmail.com	5458773801	STUDENT	GÖZDE  ŞİRİN	2026-06-03 15:11:55.196	2026-06-03 15:11:55.196	t	5458773801	\N
cmpy7fuiu01b4hke68iz3262n	kilicilayda006@gmail.com	5446291327	STUDENT	BURAK ÖNAL	2026-06-03 15:11:55.206	2026-06-03 15:11:55.206	t	5446291327	\N
cmpy7fuj301b6hke6qkky53za	mehmetgokhantucbilekk@gmail.com	5349563895	STUDENT	MEHMET GÖKHAN TUNÇBİLEK	2026-06-03 15:11:55.216	2026-06-03 15:11:55.216	t	5349563895	\N
cmpy7fujd01b8hke6t31vbw8w	a.sahin7694@gmail.com	5079510645	STUDENT	MUSTAFA ŞAHİN	2026-06-03 15:11:55.225	2026-06-03 15:11:55.225	t	5079510645	\N
cmpy7fujq01bahke6datbstsy	demirellhale@gmail.com	5339303274	STUDENT	HALE DEMİREL	2026-06-03 15:11:55.239	2026-06-03 15:11:55.239	t	5339303274	\N
cmpy7fujz01bchke6j52ooj5t	cigdemicerr@gmail.com	5520849018	STUDENT	ÇİĞDEM İÇER	2026-06-03 15:11:55.247	2026-06-03 15:11:55.247	t	5520849018	\N
cmpy7fuk901behke64ph75t0q	zsirin93@gmail.com	5520843099	STUDENT	ZEHRA ŞİRİN	2026-06-03 15:11:55.257	2026-06-03 15:11:55.257	t	5520843099	\N
cmpy7fukl01bghke6jrf8c1d9	busratryk8@gmail.com	5071177322	STUDENT	BÜŞRA TİRYAKİ	2026-06-03 15:11:55.269	2026-06-03 15:11:55.269	t	5071177322	\N
cmpy7fuky01bihke6k2ecv9oh	tunakzl35@gmail.com	5313122135	STUDENT	TUNA KIZIL	2026-06-03 15:11:55.282	2026-06-03 15:11:55.282	t	5313122135	\N
cmpy7fula01bkhke63b6kaox9	rabiayaren02@icloud.com	5360326545	STUDENT	YAREN RABİA DENİZHAN	2026-06-03 15:11:55.294	2026-06-03 15:11:55.294	t	5360326545	\N
cmpy7fulm01bmhke6zfhuvdhb	zehhracskn@gmail.com	5339486601	STUDENT	ZEHRA ŞAHİN	2026-06-03 15:11:55.306	2026-06-03 15:11:55.306	t	5339486601	\N
cmpy7fulz01bohke6ehm65nij	erdoganemre190@gmail.com	5398848418	STUDENT	EMRE ERDOĞAN	2026-06-03 15:11:55.319	2026-06-03 15:11:55.319	t	5398848418	\N
cmpy7fum901bqhke64zf4ke22	rabiadeniz585@gmail.com	5302527825	STUDENT	RABİA DENİZ	2026-06-03 15:11:55.33	2026-06-03 15:11:55.33	t	5302527825	\N
cmpy7fumj01bshke6dfzymab2	dilaracaglar1997@gmail.com	5323591997	STUDENT	İLAYDA YURTTADURMAZ	2026-06-03 15:11:55.339	2026-06-03 15:11:55.339	t	5323591997	\N
cmpy7fums01buhke6da8z3fk3	irmakyuksel4@gmail.com	5059737003	STUDENT	İREM IRMAK YÜKSEL	2026-06-03 15:11:55.348	2026-06-03 15:11:55.348	t	5059737003	\N
cmpy7fun401bwhke6yd37vaop	tunahangoksen60@gmail.com	5458388959	STUDENT	TUNAHAN GÖKŞEN	2026-06-03 15:11:55.36	2026-06-03 15:11:55.36	t	5458388959	\N
cmpy7func01byhke6tp10bv2v	melisaocak2538@hotmail.com	5350370780	STUDENT	MELİSA OCAK	2026-06-03 15:11:55.368	2026-06-03 15:11:55.368	t	5350370780	\N
cmpy7funm01c0hke6eflpwyld	Sibelipek060706@gmail.com	5539897293	STUDENT	SİBEL İPEK	2026-06-03 15:11:55.379	2026-06-03 15:11:55.379	t	5539897293	\N
cmpy7funw01c2hke6ij02sckx	acdmpp23647@hotmail.com	5383672325	STUDENT	EYÜP SAMET ÖZDOĞAN	2026-06-03 15:11:55.388	2026-06-03 15:11:55.388	t	5383672325	\N
cmpy7fuo701c4hke6v22cidva	zihni582701@hotmail.com	5316447172	STUDENT	ZİHNİ KORKMAZ	2026-06-03 15:11:55.399	2026-06-03 15:11:55.399	t	5316447172	\N
cmpy7fuog01c6hke60v3xcvnb	uzakgoksu@gmail.com	5059533626	STUDENT	GÖKSU UZAK	2026-06-03 15:11:55.409	2026-06-03 15:11:55.409	t	5059533626	\N
cmpy7fuos01c8hke6gpngdkcq	melihyanikk35@gmail.com	5467371498	STUDENT	MELİH YANIK	2026-06-03 15:11:55.42	2026-06-03 15:11:55.42	t	5467371498	\N
cmpy7fup101cahke613y1tnsf	oisik484@gmail.com	5078965083	STUDENT	ÖMER IŞIK	2026-06-03 15:11:55.429	2026-06-03 15:11:55.429	t	5078965083	\N
cmpy7fupe01cchke6f4qlepxh	ecem.deniz.ank@hotmail.com	5545980017	STUDENT	ECE DENİZ ASLAN	2026-06-03 15:11:55.442	2026-06-03 15:11:55.442	t	5545980017	\N
cmpy7fupo01cehke6io7zmqrs	ecses44@hotmail.com	5427984244	STUDENT	ESRA TURGUT	2026-06-03 15:11:55.452	2026-06-03 15:11:55.452	t	5427984244	\N
cmpy7fupy01cghke6rkgvkni6	tugbaakbiyik1@gmail.com	5376854507	STUDENT	ŞÜHEDA DEVECİ	2026-06-03 15:11:55.462	2026-06-03 15:11:55.462	t	5376854507	\N
cmpy7fuq701cihke6r9qbm4w7	hamdiyeyurttas@icloud.com	5538787057	STUDENT	HAMDİYE YURTTAŞ	2026-06-03 15:11:55.472	2026-06-03 15:11:55.472	t	5538787057	\N
cmpy7fuqy01ckhke6x2hg2fxp	cansuyucesoy48@gmail.com	5522163036	STUDENT	CANSU YÜCESOY	2026-06-03 15:11:55.499	2026-06-03 15:11:55.499	t	5522163036	\N
cmpy7fur701cmhke6h3iwq4lk	gokcen.simay@gmail.com	5337970410	STUDENT	GÖKÇEN SİMAY SADE IŞIK	2026-06-03 15:11:55.508	2026-06-03 15:11:55.508	t	5337970410	\N
cmpy7furj01cohke68n5grhqi	nefes1905@outlook.com	5330527095	STUDENT	OSMAN DÜNDAR	2026-06-03 15:11:55.519	2026-06-03 15:11:55.519	t	5330527095	\N
cmpy7furr01cqhke6jc5ujb26	ezkah2906@gmail.com	5010787840	STUDENT	EZGİ KUYUPINAR	2026-06-03 15:11:55.528	2026-06-03 15:11:55.528	t	5010787840	\N
cmpy7fus701cshke6yogw6qtf	cemiletzll@gmail.com	5076353352	STUDENT	CEMİLE TEZEL	2026-06-03 15:11:55.543	2026-06-03 15:11:55.543	t	5076353352	\N
cmpy7fusi01cuhke61enpcixt	doganumutcan@yahoo.com	5317445914	STUDENT	UMUTCAN DOĞAN	2026-06-03 15:11:55.555	2026-06-03 15:11:55.555	t	5317445914	\N
cmpy7fusv01cwhke6e2mr1jkw	haticekoca2772@gmail.com	5346846966	STUDENT	HATİCE KOCA	2026-06-03 15:11:55.567	2026-06-03 15:11:55.567	t	5346846966	\N
cmpy7fut201cyhke6n24ila1x	cigdemtiraki@gmail.com	5416313067	STUDENT	ÇİĞDEM YILMAZ	2026-06-03 15:11:55.574	2026-06-03 15:11:55.574	t	5416313067	\N
cmpy7fute01d0hke61jmiywte	muhammetenesshacioglu@gmail.com	5161623276	STUDENT	MUHAMMET ENES HACIOĞLU	2026-06-03 15:11:55.587	2026-06-03 15:11:55.587	t	5161623276	\N
cmpy7futo01d2hke6ckvh11ng	melisaltintas1453@gmail.com	5061452490	STUDENT	MELİS ALTINTAŞ	2026-06-03 15:11:55.596	2026-06-03 15:11:55.596	t	5061452490	\N
cmpy7futx01d4hke6f18y2akf	ayse_-meyveci@hotmail.com	5435043381	STUDENT	AYŞE MEYVECİ	2026-06-03 15:11:55.605	2026-06-03 15:11:55.605	t	5435043381	\N
cmpy7fuu901d6hke6wps60uh1	ozge91odabas@hotmail.com	5079777264	STUDENT	ÖZGE ODABAŞ	2026-06-03 15:11:55.617	2026-06-03 15:11:55.617	t	5079777264	\N
cmpy7fuuj01d8hke6edtu5a07	merttcannpolatt@gmail.com	5551597494	STUDENT	MERTCAN POLAT	2026-06-03 15:11:55.627	2026-06-03 15:11:55.627	t	5551597494	\N
cmpy7fuv001dahke6gha113sj	busenur004@outlook.com	5532006050	STUDENT	BUSE NUR AKSOY	2026-06-03 15:11:55.644	2026-06-03 15:11:55.644	t	5532006050	\N
cmq4wllt30001hkoumfx7plz8	akca20.97@gmail.com	5436732016	STUDENT	CİKAT AKCA	2026-06-08 07:42:51.303	2026-06-08 07:42:51.303	t	5436732016	\N
\.


--
-- Data for Name: _DirectExams; Type: TABLE DATA; Schema: public; Owner: sinavsistemi_admin
--

COPY public."_DirectExams" ("A", "B") FROM stdin;
\.


--
-- Data for Name: _ExamPackageToGroup; Type: TABLE DATA; Schema: public; Owner: sinavsistemi_admin
--

COPY public."_ExamPackageToGroup" ("A", "B") FROM stdin;
cmpxwbn3w00tihke6wrroq7vi	cmp44zr3i0017hk444oyr7dm3
cmpxwbn3w00tihke6wrroq7vi	cmp455icp004fhk44v739jonr
cmpxwbn3w00tihke6wrroq7vi	cmp455u3t0064hk44uozb26mm
cmpxwbn3w00tihke6wrroq7vi	cmp456g99009ahk44c8zcwda8
cmpxwbn3w00tihke6wrroq7vi	cmp456msw009xhk440hz1q3mu
cmpxwbn3w00tihke6wrroq7vi	cmp456u0e00bahk44vqbidbz0
cmpxwbn3w00tihke6wrroq7vi	cmp456zoa00brhk44kp4noqp8
cmpxwbn3w00tihke6wrroq7vi	cmp4575k400d2hk44wb0llax7
cmpxwbn3w00tihke6wrroq7vi	cmp457wyq00idhk44pqhw6kmc
cmpxwbn3w00tihke6wrroq7vi	cmp4588ch00oyhk44scxlin0x
cmpxwbn3w00tihke6wrroq7vi	cmp458sh600pbhk44o092kiio
cmpxwbn3w00tihke6wrroq7vi	cmplb4nw30000hkpzwrjyz8fl
cmpxwbn3w00tihke6wrroq7vi	cmpy7fudv01a8hke6voabuhhl
cmpxw13md00lahke69zt65l7w	cmp44zr3i0017hk444oyr7dm3
cmpxw13md00lahke69zt65l7w	cmp455icp004fhk44v739jonr
cmpxw13md00lahke69zt65l7w	cmp455u3t0064hk44uozb26mm
cmpxw13md00lahke69zt65l7w	cmp456g99009ahk44c8zcwda8
cmpxw13md00lahke69zt65l7w	cmp456msw009xhk440hz1q3mu
cmpxw13md00lahke69zt65l7w	cmp456u0e00bahk44vqbidbz0
cmpxw13md00lahke69zt65l7w	cmp456zoa00brhk44kp4noqp8
cmpxw13md00lahke69zt65l7w	cmp4575k400d2hk44wb0llax7
cmpxw13md00lahke69zt65l7w	cmp457wyq00idhk44pqhw6kmc
cmpxw13md00lahke69zt65l7w	cmp4588ch00oyhk44scxlin0x
cmpxw13md00lahke69zt65l7w	cmp458sh600pbhk44o092kiio
cmpxw13md00lahke69zt65l7w	cmplb4nw30000hkpzwrjyz8fl
cmpxw13md00lahke69zt65l7w	cmpy7fudv01a8hke6voabuhhl
cmpxvd3xa00d2hke6zcymlfd8	cmp44zr3i0017hk444oyr7dm3
cmpxvd3xa00d2hke6zcymlfd8	cmp455icp004fhk44v739jonr
cmpxvd3xa00d2hke6zcymlfd8	cmp455u3t0064hk44uozb26mm
cmpxvd3xa00d2hke6zcymlfd8	cmp456g99009ahk44c8zcwda8
cmpxvd3xa00d2hke6zcymlfd8	cmp456msw009xhk440hz1q3mu
cmpxvd3xa00d2hke6zcymlfd8	cmp456u0e00bahk44vqbidbz0
cmpxvd3xa00d2hke6zcymlfd8	cmp456zoa00brhk44kp4noqp8
cmpxvd3xa00d2hke6zcymlfd8	cmp4575k400d2hk44wb0llax7
cmpxvd3xa00d2hke6zcymlfd8	cmp457wyq00idhk44pqhw6kmc
cmpxvd3xa00d2hke6zcymlfd8	cmp4588ch00oyhk44scxlin0x
cmpxvd3xa00d2hke6zcymlfd8	cmp458sh600pbhk44o092kiio
cmpxvd3xa00d2hke6zcymlfd8	cmplb4nw30000hkpzwrjyz8fl
cmpxvd3xa00d2hke6zcymlfd8	cmpy7fudv01a8hke6voabuhhl
cmpxtftzd004uhke633drq8gy	cmp44zr3i0017hk444oyr7dm3
cmpxtftzd004uhke633drq8gy	cmp455icp004fhk44v739jonr
cmpxtftzd004uhke633drq8gy	cmp455u3t0064hk44uozb26mm
cmpxtftzd004uhke633drq8gy	cmp456g99009ahk44c8zcwda8
cmpxtftzd004uhke633drq8gy	cmp456msw009xhk440hz1q3mu
cmpxtftzd004uhke633drq8gy	cmp456u0e00bahk44vqbidbz0
cmpxtftzd004uhke633drq8gy	cmp456zoa00brhk44kp4noqp8
cmpxtftzd004uhke633drq8gy	cmp4575k400d2hk44wb0llax7
cmpxtftzd004uhke633drq8gy	cmp457wyq00idhk44pqhw6kmc
cmpxtftzd004uhke633drq8gy	cmp4588ch00oyhk44scxlin0x
cmpxtftzd004uhke633drq8gy	cmp458sh600pbhk44o092kiio
cmpxtftzd004uhke633drq8gy	cmplb4nw30000hkpzwrjyz8fl
cmpxtftzd004uhke633drq8gy	cmpy7fudv01a8hke6voabuhhl
cmpwugszd00g3hkwp90n25b9a	cmp44zr3i0017hk444oyr7dm3
cmpwugszd00g3hkwp90n25b9a	cmp455icp004fhk44v739jonr
cmpwugszd00g3hkwp90n25b9a	cmp455u3t0064hk44uozb26mm
cmpwugszd00g3hkwp90n25b9a	cmp456g99009ahk44c8zcwda8
cmpwugszd00g3hkwp90n25b9a	cmp456msw009xhk440hz1q3mu
cmpwugszd00g3hkwp90n25b9a	cmp456u0e00bahk44vqbidbz0
cmpwugszd00g3hkwp90n25b9a	cmp456zoa00brhk44kp4noqp8
cmpwugszd00g3hkwp90n25b9a	cmp4575k400d2hk44wb0llax7
cmpwugszd00g3hkwp90n25b9a	cmp457wyq00idhk44pqhw6kmc
cmpwugszd00g3hkwp90n25b9a	cmp4588ch00oyhk44scxlin0x
cmpwugszd00g3hkwp90n25b9a	cmp458sh600pbhk44o092kiio
cmpwugszd00g3hkwp90n25b9a	cmplb4nw30000hkpzwrjyz8fl
cmpwugszd00g3hkwp90n25b9a	cmpy7fudv01a8hke6voabuhhl
cmpwsyaiv003fhkwpc4bvp7k2	cmp44zr3i0017hk444oyr7dm3
cmpwsyaiv003fhkwpc4bvp7k2	cmp455icp004fhk44v739jonr
cmpwsyaiv003fhkwpc4bvp7k2	cmp455u3t0064hk44uozb26mm
cmpwsyaiv003fhkwpc4bvp7k2	cmp456g99009ahk44c8zcwda8
cmpwsyaiv003fhkwpc4bvp7k2	cmp456msw009xhk440hz1q3mu
cmpwsyaiv003fhkwpc4bvp7k2	cmp456u0e00bahk44vqbidbz0
cmpwsyaiv003fhkwpc4bvp7k2	cmp456zoa00brhk44kp4noqp8
cmpwsyaiv003fhkwpc4bvp7k2	cmp4575k400d2hk44wb0llax7
cmpwsyaiv003fhkwpc4bvp7k2	cmp457wyq00idhk44pqhw6kmc
cmpwsyaiv003fhkwpc4bvp7k2	cmp4588ch00oyhk44scxlin0x
cmpwsyaiv003fhkwpc4bvp7k2	cmp458sh600pbhk44o092kiio
cmpwsyaiv003fhkwpc4bvp7k2	cmplb4nw30000hkpzwrjyz8fl
cmpwsyaiv003fhkwpc4bvp7k2	cmpy7fudv01a8hke6voabuhhl
cmpgmoa5h007vhk9k9lg24vxz	cmp44zr3i0017hk444oyr7dm3
cmpgmoa5h007vhk9k9lg24vxz	cmp455icp004fhk44v739jonr
cmpgmoa5h007vhk9k9lg24vxz	cmp455u3t0064hk44uozb26mm
cmpgmoa5h007vhk9k9lg24vxz	cmp456g99009ahk44c8zcwda8
cmpgmoa5h007vhk9k9lg24vxz	cmp456msw009xhk440hz1q3mu
cmpgmoa5h007vhk9k9lg24vxz	cmp456u0e00bahk44vqbidbz0
cmpgmoa5h007vhk9k9lg24vxz	cmp456zoa00brhk44kp4noqp8
cmpgmoa5h007vhk9k9lg24vxz	cmp4575k400d2hk44wb0llax7
cmpgmoa5h007vhk9k9lg24vxz	cmp457wyq00idhk44pqhw6kmc
cmpgmoa5h007vhk9k9lg24vxz	cmp4588ch00oyhk44scxlin0x
cmpgmoa5h007vhk9k9lg24vxz	cmp458sh600pbhk44o092kiio
cmpgmoa5h007vhk9k9lg24vxz	cmplb4nw30000hkpzwrjyz8fl
cmpgmoa5h007vhk9k9lg24vxz	cmpy7fudv01a8hke6voabuhhl
cmpfkcbpz0213hkzb7z4p2re7	cmp44zr3i0017hk444oyr7dm3
cmpfkcbpz0213hkzb7z4p2re7	cmp455icp004fhk44v739jonr
cmpfkcbpz0213hkzb7z4p2re7	cmp455u3t0064hk44uozb26mm
cmpfkcbpz0213hkzb7z4p2re7	cmp456g99009ahk44c8zcwda8
cmpfkcbpz0213hkzb7z4p2re7	cmp456msw009xhk440hz1q3mu
cmpfkcbpz0213hkzb7z4p2re7	cmp456u0e00bahk44vqbidbz0
cmpfkcbpz0213hkzb7z4p2re7	cmp456zoa00brhk44kp4noqp8
cmpfkcbpz0213hkzb7z4p2re7	cmp4575k400d2hk44wb0llax7
cmpfkcbpz0213hkzb7z4p2re7	cmp457wyq00idhk44pqhw6kmc
cmpfkcbpz0213hkzb7z4p2re7	cmp4588ch00oyhk44scxlin0x
cmpfkcbpz0213hkzb7z4p2re7	cmp458sh600pbhk44o092kiio
cmpfkcbpz0213hkzb7z4p2re7	cmplb4nw30000hkpzwrjyz8fl
cmpfkcbpz0213hkzb7z4p2re7	cmpy7fudv01a8hke6voabuhhl
cmpfeyk3p01t7hkzbpf34p0yd	cmp44zr3i0017hk444oyr7dm3
cmpfeyk3p01t7hkzbpf34p0yd	cmp455icp004fhk44v739jonr
cmpfeyk3p01t7hkzbpf34p0yd	cmp455u3t0064hk44uozb26mm
cmpfeyk3p01t7hkzbpf34p0yd	cmp456g99009ahk44c8zcwda8
cmpfeyk3p01t7hkzbpf34p0yd	cmp456msw009xhk440hz1q3mu
cmpfeyk3p01t7hkzbpf34p0yd	cmp456u0e00bahk44vqbidbz0
cmpfeyk3p01t7hkzbpf34p0yd	cmp456zoa00brhk44kp4noqp8
cmpfeyk3p01t7hkzbpf34p0yd	cmp4575k400d2hk44wb0llax7
cmpfeyk3p01t7hkzbpf34p0yd	cmp457wyq00idhk44pqhw6kmc
cmpfeyk3p01t7hkzbpf34p0yd	cmp4588ch00oyhk44scxlin0x
cmpfeyk3p01t7hkzbpf34p0yd	cmp458sh600pbhk44o092kiio
cmpfeyk3p01t7hkzbpf34p0yd	cmplb4nw30000hkpzwrjyz8fl
cmpfeyk3p01t7hkzbpf34p0yd	cmpy7fudv01a8hke6voabuhhl
cmpfbt7tb006rhkzbr1k26q0j	cmp44zr3i0017hk444oyr7dm3
cmpfbt7tb006rhkzbr1k26q0j	cmp455icp004fhk44v739jonr
cmpfbt7tb006rhkzbr1k26q0j	cmp455u3t0064hk44uozb26mm
cmpfbt7tb006rhkzbr1k26q0j	cmp456g99009ahk44c8zcwda8
cmpfbt7tb006rhkzbr1k26q0j	cmp456msw009xhk440hz1q3mu
cmpfbt7tb006rhkzbr1k26q0j	cmp456u0e00bahk44vqbidbz0
cmpfbt7tb006rhkzbr1k26q0j	cmp456zoa00brhk44kp4noqp8
cmpfbt7tb006rhkzbr1k26q0j	cmp4575k400d2hk44wb0llax7
cmpfbt7tb006rhkzbr1k26q0j	cmp457wyq00idhk44pqhw6kmc
cmpfbt7tb006rhkzbr1k26q0j	cmp4588ch00oyhk44scxlin0x
cmpfbt7tb006rhkzbr1k26q0j	cmp458sh600pbhk44o092kiio
cmpfbt7tb006rhkzbr1k26q0j	cmplb4nw30000hkpzwrjyz8fl
cmpfbt7tb006rhkzbr1k26q0j	cmpy7fudv01a8hke6voabuhhl
\.


--
-- Data for Name: _ExamToGroup; Type: TABLE DATA; Schema: public; Owner: sinavsistemi_admin
--

COPY public."_ExamToGroup" ("A", "B") FROM stdin;
cmp45g62r00pshk447kwwuu5q	cmp44zr3i0017hk444oyr7dm3
cmp45g62r00pshk447kwwuu5q	cmp455icp004fhk44v739jonr
cmp45g62r00pshk447kwwuu5q	cmp455u3t0064hk44uozb26mm
cmp45g62r00pshk447kwwuu5q	cmp456g99009ahk44c8zcwda8
cmp45g62r00pshk447kwwuu5q	cmp456msw009xhk440hz1q3mu
cmp45g62r00pshk447kwwuu5q	cmp456u0e00bahk44vqbidbz0
cmp45g62r00pshk447kwwuu5q	cmp456zoa00brhk44kp4noqp8
cmp45g62r00pshk447kwwuu5q	cmp4575k400d2hk44wb0llax7
cmp45g62r00pshk447kwwuu5q	cmp457wyq00idhk44pqhw6kmc
cmp45g62r00pshk447kwwuu5q	cmp4588ch00oyhk44scxlin0x
cmp45g62r00pshk447kwwuu5q	cmp458sh600pbhk44o092kiio
cmp45g62r00pshk447kwwuu5q	cmplb4nw30000hkpzwrjyz8fl
cmp45g62r00pshk447kwwuu5q	cmpy7fudv01a8hke6voabuhhl
cmpceha6h002dhkdzrrzyzdbv	cmp44zr3i0017hk444oyr7dm3
cmpceha6h002dhkdzrrzyzdbv	cmp455icp004fhk44v739jonr
cmpceha6h002dhkdzrrzyzdbv	cmp455u3t0064hk44uozb26mm
cmpceha6h002dhkdzrrzyzdbv	cmp456g99009ahk44c8zcwda8
cmpceha6h002dhkdzrrzyzdbv	cmp456msw009xhk440hz1q3mu
cmpceha6h002dhkdzrrzyzdbv	cmp456u0e00bahk44vqbidbz0
cmpceha6h002dhkdzrrzyzdbv	cmp456zoa00brhk44kp4noqp8
cmpceha6h002dhkdzrrzyzdbv	cmp4575k400d2hk44wb0llax7
cmpceha6h002dhkdzrrzyzdbv	cmp457wyq00idhk44pqhw6kmc
cmpceha6h002dhkdzrrzyzdbv	cmp4588ch00oyhk44scxlin0x
cmpceha6h002dhkdzrrzyzdbv	cmp458sh600pbhk44o092kiio
cmpceha6h002dhkdzrrzyzdbv	cmplb4nw30000hkpzwrjyz8fl
cmpceha6h002dhkdzrrzyzdbv	cmpy7fudv01a8hke6voabuhhl
cmpcfd9it0089hkdz1pm9fzpp	cmp44zr3i0017hk444oyr7dm3
cmpcfd9it0089hkdz1pm9fzpp	cmp455icp004fhk44v739jonr
cmpcfd9it0089hkdz1pm9fzpp	cmp455u3t0064hk44uozb26mm
cmpcfd9it0089hkdz1pm9fzpp	cmp456g99009ahk44c8zcwda8
cmpcfd9it0089hkdz1pm9fzpp	cmp456msw009xhk440hz1q3mu
cmpcfd9it0089hkdz1pm9fzpp	cmp456u0e00bahk44vqbidbz0
cmpcfd9it0089hkdz1pm9fzpp	cmp456zoa00brhk44kp4noqp8
cmpcfd9it0089hkdz1pm9fzpp	cmp4575k400d2hk44wb0llax7
cmpcfd9it0089hkdz1pm9fzpp	cmp457wyq00idhk44pqhw6kmc
cmpcfd9it0089hkdz1pm9fzpp	cmp4588ch00oyhk44scxlin0x
cmpcfd9it0089hkdz1pm9fzpp	cmp458sh600pbhk44o092kiio
cmpcfd9it0089hkdz1pm9fzpp	cmplb4nw30000hkpzwrjyz8fl
cmpcfd9it0089hkdz1pm9fzpp	cmpy7fudv01a8hke6voabuhhl
cmpwufjvi00eyhkwp5jo44dff	cmp44zr3i0017hk444oyr7dm3
cmpwufjvi00eyhkwp5jo44dff	cmp455icp004fhk44v739jonr
cmpwufjvi00eyhkwp5jo44dff	cmp455u3t0064hk44uozb26mm
cmpwufjvi00eyhkwp5jo44dff	cmp456g99009ahk44c8zcwda8
cmpwufjvi00eyhkwp5jo44dff	cmp456msw009xhk440hz1q3mu
cmpwufjvi00eyhkwp5jo44dff	cmp456u0e00bahk44vqbidbz0
cmpwufjvi00eyhkwp5jo44dff	cmp456zoa00brhk44kp4noqp8
cmpwufjvi00eyhkwp5jo44dff	cmp4575k400d2hk44wb0llax7
cmpwufjvi00eyhkwp5jo44dff	cmp457wyq00idhk44pqhw6kmc
cmpxvwgb700hrhke60gvfnxza	cmp44zr3i0017hk444oyr7dm3
cmpxvwgb700hrhke60gvfnxza	cmp455icp004fhk44v739jonr
cmpxvwgb700hrhke60gvfnxza	cmp455u3t0064hk44uozb26mm
cmpxvwgb700hrhke60gvfnxza	cmp456g99009ahk44c8zcwda8
cmpxvwgb700hrhke60gvfnxza	cmp456msw009xhk440hz1q3mu
cmpxvwgb700hrhke60gvfnxza	cmp456u0e00bahk44vqbidbz0
cmpxvwgb700hrhke60gvfnxza	cmp456zoa00brhk44kp4noqp8
cmpxvwgb700hrhke60gvfnxza	cmp4575k400d2hk44wb0llax7
cmpxvwgb700hrhke60gvfnxza	cmp457wyq00idhk44pqhw6kmc
cmpxvwgb700hrhke60gvfnxza	cmp4588ch00oyhk44scxlin0x
cmpxw7hz500pzhke6tmzzhqma	cmp44zr3i0017hk444oyr7dm3
cmpxw7hz500pzhke6tmzzhqma	cmp455icp004fhk44v739jonr
cmpxw7hz500pzhke6tmzzhqma	cmp455u3t0064hk44uozb26mm
cmpxw7hz500pzhke6tmzzhqma	cmp456g99009ahk44c8zcwda8
cmpxw7hz500pzhke6tmzzhqma	cmp456msw009xhk440hz1q3mu
cmpxw7hz500pzhke6tmzzhqma	cmp456u0e00bahk44vqbidbz0
cmpxw7hz500pzhke6tmzzhqma	cmp456zoa00brhk44kp4noqp8
cmpxw7hz500pzhke6tmzzhqma	cmp4575k400d2hk44wb0llax7
cmpxw7hz500pzhke6tmzzhqma	cmp457wyq00idhk44pqhw6kmc
cmpxw7hz500pzhke6tmzzhqma	cmp4588ch00oyhk44scxlin0x
cmpxw7hz500pzhke6tmzzhqma	cmp458sh600pbhk44o092kiio
cmpxw7hz500pzhke6tmzzhqma	cmplb4nw30000hkpzwrjyz8fl
cmpxw7hz500pzhke6tmzzhqma	cmpy7fudv01a8hke6voabuhhl
cmpxw5zub00oshke69lnxt9hl	cmp44zr3i0017hk444oyr7dm3
cmpxw5zub00oshke69lnxt9hl	cmp455icp004fhk44v739jonr
cmpxw5zub00oshke69lnxt9hl	cmp455u3t0064hk44uozb26mm
cmpxw5zub00oshke69lnxt9hl	cmp456g99009ahk44c8zcwda8
cmpxw5zub00oshke69lnxt9hl	cmp456msw009xhk440hz1q3mu
cmpxw5zub00oshke69lnxt9hl	cmp456u0e00bahk44vqbidbz0
cmpxw5zub00oshke69lnxt9hl	cmp456zoa00brhk44kp4noqp8
cmpxw5zub00oshke69lnxt9hl	cmp4575k400d2hk44wb0llax7
cmpxw5zub00oshke69lnxt9hl	cmp457wyq00idhk44pqhw6kmc
cmpxw5zub00oshke69lnxt9hl	cmp4588ch00oyhk44scxlin0x
cmpxw5zub00oshke69lnxt9hl	cmp458sh600pbhk44o092kiio
cmpxw5zub00oshke69lnxt9hl	cmplb4nw30000hkpzwrjyz8fl
cmpxw5zub00oshke69lnxt9hl	cmpy7fudv01a8hke6voabuhhl
cmpcmu9th010mhkdzuyws3446	cmp44zr3i0017hk444oyr7dm3
cmpcmu9th010mhkdzuyws3446	cmp455icp004fhk44v739jonr
cmpcmu9th010mhkdzuyws3446	cmp455u3t0064hk44uozb26mm
cmpcmu9th010mhkdzuyws3446	cmp456g99009ahk44c8zcwda8
cmpcmu9th010mhkdzuyws3446	cmp456msw009xhk440hz1q3mu
cmpcmu9th010mhkdzuyws3446	cmp456u0e00bahk44vqbidbz0
cmpcmu9th010mhkdzuyws3446	cmp456zoa00brhk44kp4noqp8
cmpcmu9th010mhkdzuyws3446	cmp4575k400d2hk44wb0llax7
cmpcmu9th010mhkdzuyws3446	cmp457wyq00idhk44pqhw6kmc
cmpcmu9th010mhkdzuyws3446	cmp4588ch00oyhk44scxlin0x
cmpcmu9th010mhkdzuyws3446	cmp458sh600pbhk44o092kiio
cmpcmu9th010mhkdzuyws3446	cmplb4nw30000hkpzwrjyz8fl
cmpwufjvi00eyhkwp5jo44dff	cmp4588ch00oyhk44scxlin0x
cmpwufjvi00eyhkwp5jo44dff	cmp458sh600pbhk44o092kiio
cmpwufjvi00eyhkwp5jo44dff	cmplb4nw30000hkpzwrjyz8fl
cmpwufjvi00eyhkwp5jo44dff	cmpy7fudv01a8hke6voabuhhl
cmpwu7wz500cnhkwpbjuja1wf	cmp44zr3i0017hk444oyr7dm3
cmpwu7wz500cnhkwpbjuja1wf	cmp455icp004fhk44v739jonr
cmpwu7wz500cnhkwpbjuja1wf	cmp455u3t0064hk44uozb26mm
cmpwu7wz500cnhkwpbjuja1wf	cmp456g99009ahk44c8zcwda8
cmpwu7wz500cnhkwpbjuja1wf	cmp456msw009xhk440hz1q3mu
cmpwu7wz500cnhkwpbjuja1wf	cmp456u0e00bahk44vqbidbz0
cmpwu7wz500cnhkwpbjuja1wf	cmp456zoa00brhk44kp4noqp8
cmpwu7wz500cnhkwpbjuja1wf	cmp4575k400d2hk44wb0llax7
cmpxw4fdb00ldhke6mjnc94ez	cmp44zr3i0017hk444oyr7dm3
cmpxw4fdb00ldhke6mjnc94ez	cmp455cds003mhk44nkrnvnb8
cmpxw4fdb00ldhke6mjnc94ez	cmp455icp004fhk44v739jonr
cmpxw4fdb00ldhke6mjnc94ez	cmp455u3t0064hk44uozb26mm
cmpxw4fdb00ldhke6mjnc94ez	cmp4569ha008dhk4407omxehu
cmpxw4fdb00ldhke6mjnc94ez	cmp456g99009ahk44c8zcwda8
cmpxw4fdb00ldhke6mjnc94ez	cmp456msw009xhk440hz1q3mu
cmpxw4fdb00ldhke6mjnc94ez	cmp456u0e00bahk44vqbidbz0
cmpxw4fdb00ldhke6mjnc94ez	cmp456zoa00brhk44kp4noqp8
cmpxw4fdb00ldhke6mjnc94ez	cmp4575k400d2hk44wb0llax7
cmpxw4fdb00ldhke6mjnc94ez	cmp457wyq00idhk44pqhw6kmc
cmpxw4fdb00ldhke6mjnc94ez	cmp4588ch00oyhk44scxlin0x
cmpxw4fdb00ldhke6mjnc94ez	cmp458sh600pbhk44o092kiio
cmpxw4fdb00ldhke6mjnc94ez	cmplb4nw30000hkpzwrjyz8fl
cmpxw4fdb00ldhke6mjnc94ez	cmpy7fudv01a8hke6voabuhhl
cmpxw01dc00k5hke61wbi7nqp	cmp44zr3i0017hk444oyr7dm3
cmpxw01dc00k5hke61wbi7nqp	cmp455icp004fhk44v739jonr
cmpxw01dc00k5hke61wbi7nqp	cmp455u3t0064hk44uozb26mm
cmpxw01dc00k5hke61wbi7nqp	cmp456g99009ahk44c8zcwda8
cmpxw01dc00k5hke61wbi7nqp	cmp456msw009xhk440hz1q3mu
cmpxw01dc00k5hke61wbi7nqp	cmp456u0e00bahk44vqbidbz0
cmpcmu9th010mhkdzuyws3446	cmpy7fudv01a8hke6voabuhhl
cmpxw01dc00k5hke61wbi7nqp	cmp456zoa00brhk44kp4noqp8
cmpxw01dc00k5hke61wbi7nqp	cmp4575k400d2hk44wb0llax7
cmpwu7wz500cnhkwpbjuja1wf	cmp457wyq00idhk44pqhw6kmc
cmpwu7wz500cnhkwpbjuja1wf	cmp4588ch00oyhk44scxlin0x
cmpwu7wz500cnhkwpbjuja1wf	cmp458sh600pbhk44o092kiio
cmpwu7wz500cnhkwpbjuja1wf	cmplb4nw30000hkpzwrjyz8fl
cmpwu7wz500cnhkwpbjuja1wf	cmpy7fudv01a8hke6voabuhhl
cmpwti7yo00a9hkwpb12fvmcd	cmp44zr3i0017hk444oyr7dm3
cmpwti7yo00a9hkwpb12fvmcd	cmp455icp004fhk44v739jonr
cmpwti7yo00a9hkwpb12fvmcd	cmp455u3t0064hk44uozb26mm
cmpwti7yo00a9hkwpb12fvmcd	cmp456g99009ahk44c8zcwda8
cmpwti7yo00a9hkwpb12fvmcd	cmp456msw009xhk440hz1q3mu
cmpwti7yo00a9hkwpb12fvmcd	cmp456u0e00bahk44vqbidbz0
cmpwti7yo00a9hkwpb12fvmcd	cmp456zoa00brhk44kp4noqp8
cmpwti7yo00a9hkwpb12fvmcd	cmp4575k400d2hk44wb0llax7
cmpwti7yo00a9hkwpb12fvmcd	cmp457wyq00idhk44pqhw6kmc
cmpwti7yo00a9hkwpb12fvmcd	cmp4588ch00oyhk44scxlin0x
cmpwti7yo00a9hkwpb12fvmcd	cmp458sh600pbhk44o092kiio
cmpwti7yo00a9hkwpb12fvmcd	cmplb4nw30000hkpzwrjyz8fl
cmpwti7yo00a9hkwpb12fvmcd	cmpy7fudv01a8hke6voabuhhl
cmp5jiu2e0019hkntf5ix2t9l	cmp44zr3i0017hk444oyr7dm3
cmp5jiu2e0019hkntf5ix2t9l	cmp455icp004fhk44v739jonr
cmp5jiu2e0019hkntf5ix2t9l	cmp455u3t0064hk44uozb26mm
cmp5jiu2e0019hkntf5ix2t9l	cmp456g99009ahk44c8zcwda8
cmp5jiu2e0019hkntf5ix2t9l	cmp456msw009xhk440hz1q3mu
cmp5jiu2e0019hkntf5ix2t9l	cmp456u0e00bahk44vqbidbz0
cmp5jiu2e0019hkntf5ix2t9l	cmp456zoa00brhk44kp4noqp8
cmp5jiu2e0019hkntf5ix2t9l	cmp4575k400d2hk44wb0llax7
cmp5jiu2e0019hkntf5ix2t9l	cmp457wyq00idhk44pqhw6kmc
cmp5jiu2e0019hkntf5ix2t9l	cmp4588ch00oyhk44scxlin0x
cmp5jiu2e0019hkntf5ix2t9l	cmp458sh600pbhk44o092kiio
cmp5jiu2e0019hkntf5ix2t9l	cmplb4nw30000hkpzwrjyz8fl
cmp5jiu2e0019hkntf5ix2t9l	cmpy7fudv01a8hke6voabuhhl
cmp5j8xvh0002hkntbvhrqecu	cmp44zr3i0017hk444oyr7dm3
cmp5j8xvh0002hkntbvhrqecu	cmp455icp004fhk44v739jonr
cmp5j8xvh0002hkntbvhrqecu	cmp455u3t0064hk44uozb26mm
cmp5j8xvh0002hkntbvhrqecu	cmp456g99009ahk44c8zcwda8
cmp5j8xvh0002hkntbvhrqecu	cmp456msw009xhk440hz1q3mu
cmp5j8xvh0002hkntbvhrqecu	cmp456u0e00bahk44vqbidbz0
cmp5j8xvh0002hkntbvhrqecu	cmp456zoa00brhk44kp4noqp8
cmp5j8xvh0002hkntbvhrqecu	cmp4575k400d2hk44wb0llax7
cmp5j8xvh0002hkntbvhrqecu	cmp457wyq00idhk44pqhw6kmc
cmp5j8xvh0002hkntbvhrqecu	cmp4588ch00oyhk44scxlin0x
cmp5j8xvh0002hkntbvhrqecu	cmp458sh600pbhk44o092kiio
cmp5j8xvh0002hkntbvhrqecu	cmplb4nw30000hkpzwrjyz8fl
cmp5j8xvh0002hkntbvhrqecu	cmpy7fudv01a8hke6voabuhhl
cmpcnbiae017jhkdzjao1489e	cmp44zr3i0017hk444oyr7dm3
cmpcnbiae017jhkdzjao1489e	cmp455icp004fhk44v739jonr
cmpcnbiae017jhkdzjao1489e	cmp455u3t0064hk44uozb26mm
cmpcnbiae017jhkdzjao1489e	cmp456g99009ahk44c8zcwda8
cmpcnbiae017jhkdzjao1489e	cmp456msw009xhk440hz1q3mu
cmpcnbiae017jhkdzjao1489e	cmp456u0e00bahk44vqbidbz0
cmpcnbiae017jhkdzjao1489e	cmp456zoa00brhk44kp4noqp8
cmpcnbiae017jhkdzjao1489e	cmp4575k400d2hk44wb0llax7
cmpcnbiae017jhkdzjao1489e	cmp457wyq00idhk44pqhw6kmc
cmpcnbiae017jhkdzjao1489e	cmp4588ch00oyhk44scxlin0x
cmpcnbiae017jhkdzjao1489e	cmp458sh600pbhk44o092kiio
cmpcnbiae017jhkdzjao1489e	cmplb4nw30000hkpzwrjyz8fl
cmpcnbiae017jhkdzjao1489e	cmpy7fudv01a8hke6voabuhhl
cmpcj8j9c00ybhkdzctaisitd	cmp44zr3i0017hk444oyr7dm3
cmpcj8j9c00ybhkdzctaisitd	cmp455icp004fhk44v739jonr
cmpcj8j9c00ybhkdzctaisitd	cmp455u3t0064hk44uozb26mm
cmpcj8j9c00ybhkdzctaisitd	cmp456g99009ahk44c8zcwda8
cmpcj8j9c00ybhkdzctaisitd	cmp456msw009xhk440hz1q3mu
cmpcj8j9c00ybhkdzctaisitd	cmp456u0e00bahk44vqbidbz0
cmpcj8j9c00ybhkdzctaisitd	cmp456zoa00brhk44kp4noqp8
cmpcj8j9c00ybhkdzctaisitd	cmp4575k400d2hk44wb0llax7
cmpcj8j9c00ybhkdzctaisitd	cmp457wyq00idhk44pqhw6kmc
cmpcj8j9c00ybhkdzctaisitd	cmp4588ch00oyhk44scxlin0x
cmpcirzfp00tphkdz1ul5o9la	cmp44zr3i0017hk444oyr7dm3
cmpcirzfp00tphkdz1ul5o9la	cmp455icp004fhk44v739jonr
cmpcirzfp00tphkdz1ul5o9la	cmp455u3t0064hk44uozb26mm
cmpcirzfp00tphkdz1ul5o9la	cmp456g99009ahk44c8zcwda8
cmpcj8j9c00ybhkdzctaisitd	cmp458sh600pbhk44o092kiio
cmpcj8j9c00ybhkdzctaisitd	cmplb4nw30000hkpzwrjyz8fl
cmpcj8j9c00ybhkdzctaisitd	cmpy7fudv01a8hke6voabuhhl
cmpcirzfp00tphkdz1ul5o9la	cmp456msw009xhk440hz1q3mu
cmpcirzfp00tphkdz1ul5o9la	cmp456u0e00bahk44vqbidbz0
cmpcirzfp00tphkdz1ul5o9la	cmp456zoa00brhk44kp4noqp8
cmpcirzfp00tphkdz1ul5o9la	cmp4575k400d2hk44wb0llax7
cmpcirzfp00tphkdz1ul5o9la	cmp457wyq00idhk44pqhw6kmc
cmpcirzfp00tphkdz1ul5o9la	cmp4588ch00oyhk44scxlin0x
cmpcirzfp00tphkdz1ul5o9la	cmp458sh600pbhk44o092kiio
cmpcirzfp00tphkdz1ul5o9la	cmplb4nw30000hkpzwrjyz8fl
cmpcirzfp00tphkdz1ul5o9la	cmpy7fudv01a8hke6voabuhhl
cmpcmzxsi012xhkdzrbj8fjy8	cmp44zr3i0017hk444oyr7dm3
cmpcmzxsi012xhkdzrbj8fjy8	cmp455icp004fhk44v739jonr
cmpcmzxsi012xhkdzrbj8fjy8	cmp455u3t0064hk44uozb26mm
cmpcmzxsi012xhkdzrbj8fjy8	cmp456g99009ahk44c8zcwda8
cmpcmzxsi012xhkdzrbj8fjy8	cmp456msw009xhk440hz1q3mu
cmpcmzxsi012xhkdzrbj8fjy8	cmp456u0e00bahk44vqbidbz0
cmpcmzxsi012xhkdzrbj8fjy8	cmp456zoa00brhk44kp4noqp8
cmpcmzxsi012xhkdzrbj8fjy8	cmp4575k400d2hk44wb0llax7
cmpcmzxsi012xhkdzrbj8fjy8	cmp457wyq00idhk44pqhw6kmc
cmpcmzxsi012xhkdzrbj8fjy8	cmp4588ch00oyhk44scxlin0x
cmpcmzxsi012xhkdzrbj8fjy8	cmp458sh600pbhk44o092kiio
cmpcmzxsi012xhkdzrbj8fjy8	cmplb4nw30000hkpzwrjyz8fl
cmpcmzxsi012xhkdzrbj8fjy8	cmpy7fudv01a8hke6voabuhhl
cmpwtnr2b00bghkwp97a1ohni	cmp44zr3i0017hk444oyr7dm3
cmpwtnr2b00bghkwp97a1ohni	cmp455icp004fhk44v739jonr
cmpwtnr2b00bghkwp97a1ohni	cmp455u3t0064hk44uozb26mm
cmpwtnr2b00bghkwp97a1ohni	cmp456g99009ahk44c8zcwda8
cmpwtnr2b00bghkwp97a1ohni	cmp456msw009xhk440hz1q3mu
cmpwtnr2b00bghkwp97a1ohni	cmp456u0e00bahk44vqbidbz0
cmpwtnr2b00bghkwp97a1ohni	cmp456zoa00brhk44kp4noqp8
cmpwtnr2b00bghkwp97a1ohni	cmp4575k400d2hk44wb0llax7
cmpwtnr2b00bghkwp97a1ohni	cmp457wyq00idhk44pqhw6kmc
cmpwtnr2b00bghkwp97a1ohni	cmp4588ch00oyhk44scxlin0x
cmpwtnr2b00bghkwp97a1ohni	cmp458sh600pbhk44o092kiio
cmpwtnr2b00bghkwp97a1ohni	cmplb4nw30000hkpzwrjyz8fl
cmpwtnr2b00bghkwp97a1ohni	cmpy7fudv01a8hke6voabuhhl
cmpxvwgb700hrhke60gvfnxza	cmp458sh600pbhk44o092kiio
cmpxvwgb700hrhke60gvfnxza	cmplb4nw30000hkpzwrjyz8fl
cmpxvwgb700hrhke60gvfnxza	cmpy7fudv01a8hke6voabuhhl
cmpxw9h0j00r6hke6jgtdhnth	cmp44zr3i0017hk444oyr7dm3
cmpxw9h0j00r6hke6jgtdhnth	cmp455icp004fhk44v739jonr
cmpxw9h0j00r6hke6jgtdhnth	cmp455u3t0064hk44uozb26mm
cmpxw9h0j00r6hke6jgtdhnth	cmp456g99009ahk44c8zcwda8
cmpxw9h0j00r6hke6jgtdhnth	cmp456msw009xhk440hz1q3mu
cmpxw9h0j00r6hke6jgtdhnth	cmp456u0e00bahk44vqbidbz0
cmpxw9h0j00r6hke6jgtdhnth	cmp456zoa00brhk44kp4noqp8
cmpxw9h0j00r6hke6jgtdhnth	cmp4575k400d2hk44wb0llax7
cmpxw9h0j00r6hke6jgtdhnth	cmp457wyq00idhk44pqhw6kmc
cmpxw9h0j00r6hke6jgtdhnth	cmp4588ch00oyhk44scxlin0x
cmpxw9h0j00r6hke6jgtdhnth	cmp458sh600pbhk44o092kiio
cmpxw9h0j00r6hke6jgtdhnth	cmplb4nw30000hkpzwrjyz8fl
cmpcn4fom0158hkdzn2o5idv8	cmp44zr3i0017hk444oyr7dm3
cmpcn4fom0158hkdzn2o5idv8	cmp455icp004fhk44v739jonr
cmpcn4fom0158hkdzn2o5idv8	cmp455u3t0064hk44uozb26mm
cmpcn4fom0158hkdzn2o5idv8	cmp456g99009ahk44c8zcwda8
cmpcn4fom0158hkdzn2o5idv8	cmp456msw009xhk440hz1q3mu
cmpcn4fom0158hkdzn2o5idv8	cmp456u0e00bahk44vqbidbz0
cmpcn4fom0158hkdzn2o5idv8	cmp456zoa00brhk44kp4noqp8
cmpcn4fom0158hkdzn2o5idv8	cmp4575k400d2hk44wb0llax7
cmpcn4fom0158hkdzn2o5idv8	cmp457wyq00idhk44pqhw6kmc
cmpcn4fom0158hkdzn2o5idv8	cmp4588ch00oyhk44scxlin0x
cmpcn4fom0158hkdzn2o5idv8	cmp458sh600pbhk44o092kiio
cmpcn4fom0158hkdzn2o5idv8	cmplb4nw30000hkpzwrjyz8fl
cmpcn4fom0158hkdzn2o5idv8	cmpy7fudv01a8hke6voabuhhl
cmpxw01dc00k5hke61wbi7nqp	cmp457wyq00idhk44pqhw6kmc
cmpxw01dc00k5hke61wbi7nqp	cmp4588ch00oyhk44scxlin0x
cmpxw01dc00k5hke61wbi7nqp	cmp458sh600pbhk44o092kiio
cmpxw01dc00k5hke61wbi7nqp	cmplb4nw30000hkpzwrjyz8fl
cmpxw01dc00k5hke61wbi7nqp	cmpy7fudv01a8hke6voabuhhl
cmpxvy55s00iyhke6ha2zs62d	cmp44zr3i0017hk444oyr7dm3
cmpxvy55s00iyhke6ha2zs62d	cmp455icp004fhk44v739jonr
cmpxvy55s00iyhke6ha2zs62d	cmp455u3t0064hk44uozb26mm
cmpxvy55s00iyhke6ha2zs62d	cmp456g99009ahk44c8zcwda8
cmpxvy55s00iyhke6ha2zs62d	cmp456msw009xhk440hz1q3mu
cmpxvy55s00iyhke6ha2zs62d	cmp456u0e00bahk44vqbidbz0
cmpxvy55s00iyhke6ha2zs62d	cmp456zoa00brhk44kp4noqp8
cmpxvy55s00iyhke6ha2zs62d	cmp4575k400d2hk44wb0llax7
cmpxvy55s00iyhke6ha2zs62d	cmp457wyq00idhk44pqhw6kmc
cmpxvy55s00iyhke6ha2zs62d	cmp4588ch00oyhk44scxlin0x
cmpxvy55s00iyhke6ha2zs62d	cmp458sh600pbhk44o092kiio
cmpxvy55s00iyhke6ha2zs62d	cmplb4nw30000hkpzwrjyz8fl
cmpxvy55s00iyhke6ha2zs62d	cmpy7fudv01a8hke6voabuhhl
cmpxsu9qy003phke65kkykwv8	cmp44zr3i0017hk444oyr7dm3
cmpxsu9qy003phke65kkykwv8	cmp455icp004fhk44v739jonr
cmpxsu9qy003phke65kkykwv8	cmp455u3t0064hk44uozb26mm
cmpxsu9qy003phke65kkykwv8	cmp456g99009ahk44c8zcwda8
cmpxsu9qy003phke65kkykwv8	cmp456msw009xhk440hz1q3mu
cmpxsd15o001bhke6zja5eqfk	cmp44zr3i0017hk444oyr7dm3
cmpxsd15o001bhke6zja5eqfk	cmp455icp004fhk44v739jonr
cmpxsd15o001bhke6zja5eqfk	cmp455u3t0064hk44uozb26mm
cmpxsd15o001bhke6zja5eqfk	cmp456g99009ahk44c8zcwda8
cmpxsu9qy003phke65kkykwv8	cmp456u0e00bahk44vqbidbz0
cmpxsu9qy003phke65kkykwv8	cmp456zoa00brhk44kp4noqp8
cmpxsu9qy003phke65kkykwv8	cmp4575k400d2hk44wb0llax7
cmpxsu9qy003phke65kkykwv8	cmp457wyq00idhk44pqhw6kmc
cmpxsu9qy003phke65kkykwv8	cmp4588ch00oyhk44scxlin0x
cmpxsu9qy003phke65kkykwv8	cmp458sh600pbhk44o092kiio
cmpxsu9qy003phke65kkykwv8	cmplb4nw30000hkpzwrjyz8fl
cmpxsu9qy003phke65kkykwv8	cmpy7fudv01a8hke6voabuhhl
cmpxshh83002ihke6w6k0fvdx	cmp44zr3i0017hk444oyr7dm3
cmpxshh83002ihke6w6k0fvdx	cmp455icp004fhk44v739jonr
cmpxshh83002ihke6w6k0fvdx	cmp455u3t0064hk44uozb26mm
cmpxshh83002ihke6w6k0fvdx	cmp456g99009ahk44c8zcwda8
cmpxshh83002ihke6w6k0fvdx	cmp456msw009xhk440hz1q3mu
cmpxshh83002ihke6w6k0fvdx	cmp456u0e00bahk44vqbidbz0
cmpxshh83002ihke6w6k0fvdx	cmp456zoa00brhk44kp4noqp8
cmpxshh83002ihke6w6k0fvdx	cmp4575k400d2hk44wb0llax7
cmpxshh83002ihke6w6k0fvdx	cmp457wyq00idhk44pqhw6kmc
cmpxshh83002ihke6w6k0fvdx	cmp4588ch00oyhk44scxlin0x
cmpxshh83002ihke6w6k0fvdx	cmp458sh600pbhk44o092kiio
cmpxshh83002ihke6w6k0fvdx	cmplb4nw30000hkpzwrjyz8fl
cmpxshh83002ihke6w6k0fvdx	cmpy7fudv01a8hke6voabuhhl
cmpxrepeb0004hke67fbajpe7	cmp44zr3i0017hk444oyr7dm3
cmpxsd15o001bhke6zja5eqfk	cmp456msw009xhk440hz1q3mu
cmpxsd15o001bhke6zja5eqfk	cmp456u0e00bahk44vqbidbz0
cmpxsd15o001bhke6zja5eqfk	cmp456zoa00brhk44kp4noqp8
cmpxsd15o001bhke6zja5eqfk	cmp4575k400d2hk44wb0llax7
cmpxsd15o001bhke6zja5eqfk	cmp457wyq00idhk44pqhw6kmc
cmpxsd15o001bhke6zja5eqfk	cmp4588ch00oyhk44scxlin0x
cmpxsd15o001bhke6zja5eqfk	cmp458sh600pbhk44o092kiio
cmpxsd15o001bhke6zja5eqfk	cmplb4nw30000hkpzwrjyz8fl
cmpxsd15o001bhke6zja5eqfk	cmpy7fudv01a8hke6voabuhhl
cmpxw9h0j00r6hke6jgtdhnth	cmpy7fudv01a8hke6voabuhhl
cmpxwaxx600sdhke69schfi8y	cmp44zr3i0017hk444oyr7dm3
cmpxwaxx600sdhke69schfi8y	cmp455icp004fhk44v739jonr
cmpxwaxx600sdhke69schfi8y	cmp455u3t0064hk44uozb26mm
cmpxwaxx600sdhke69schfi8y	cmp456g99009ahk44c8zcwda8
cmpxwaxx600sdhke69schfi8y	cmp456msw009xhk440hz1q3mu
cmpxwaxx600sdhke69schfi8y	cmp456u0e00bahk44vqbidbz0
cmpxwaxx600sdhke69schfi8y	cmp456zoa00brhk44kp4noqp8
cmpxwaxx600sdhke69schfi8y	cmp4575k400d2hk44wb0llax7
cmpxwaxx600sdhke69schfi8y	cmp457wyq00idhk44pqhw6kmc
cmpxwaxx600sdhke69schfi8y	cmp4588ch00oyhk44scxlin0x
cmpxwaxx600sdhke69schfi8y	cmp458sh600pbhk44o092kiio
cmpxrepeb0004hke67fbajpe7	cmp455icp004fhk44v739jonr
cmpxrepeb0004hke67fbajpe7	cmp455u3t0064hk44uozb26mm
cmpxrepeb0004hke67fbajpe7	cmp456g99009ahk44c8zcwda8
cmpxrepeb0004hke67fbajpe7	cmp456msw009xhk440hz1q3mu
cmpxrepeb0004hke67fbajpe7	cmp456u0e00bahk44vqbidbz0
cmpxrepeb0004hke67fbajpe7	cmp456zoa00brhk44kp4noqp8
cmpxrepeb0004hke67fbajpe7	cmp4575k400d2hk44wb0llax7
cmpxrepeb0004hke67fbajpe7	cmp457wyq00idhk44pqhw6kmc
cmpxrepeb0004hke67fbajpe7	cmp4588ch00oyhk44scxlin0x
cmpxrepeb0004hke67fbajpe7	cmp458sh600pbhk44o092kiio
cmpxrepeb0004hke67fbajpe7	cmplb4nw30000hkpzwrjyz8fl
cmpxrepeb0004hke67fbajpe7	cmpy7fudv01a8hke6voabuhhl
cmpxvuq1d00gkhke6xmwxml94	cmp44zr3i0017hk444oyr7dm3
cmpxvuq1d00gkhke6xmwxml94	cmp455icp004fhk44v739jonr
cmpciwqq700w0hkdzjbgaqxol	cmp44zr3i0017hk444oyr7dm3
cmpciwqq700w0hkdzjbgaqxol	cmp455icp004fhk44v739jonr
cmpciwqq700w0hkdzjbgaqxol	cmp455u3t0064hk44uozb26mm
cmpciwqq700w0hkdzjbgaqxol	cmp456g99009ahk44c8zcwda8
cmpciwqq700w0hkdzjbgaqxol	cmp456msw009xhk440hz1q3mu
cmpciwqq700w0hkdzjbgaqxol	cmp456u0e00bahk44vqbidbz0
cmpciwqq700w0hkdzjbgaqxol	cmp456zoa00brhk44kp4noqp8
cmpciwqq700w0hkdzjbgaqxol	cmp4575k400d2hk44wb0llax7
cmpciwqq700w0hkdzjbgaqxol	cmp457wyq00idhk44pqhw6kmc
cmpciwqq700w0hkdzjbgaqxol	cmp4588ch00oyhk44scxlin0x
cmpciwqq700w0hkdzjbgaqxol	cmp458sh600pbhk44o092kiio
cmpciwqq700w0hkdzjbgaqxol	cmplb4nw30000hkpzwrjyz8fl
cmpciwqq700w0hkdzjbgaqxol	cmpy7fudv01a8hke6voabuhhl
cmpch8fca00rehkdz8hbidxis	cmp44zr3i0017hk444oyr7dm3
cmpch8fca00rehkdz8hbidxis	cmp455icp004fhk44v739jonr
cmpch8fca00rehkdz8hbidxis	cmp455u3t0064hk44uozb26mm
cmpch8fca00rehkdz8hbidxis	cmp456g99009ahk44c8zcwda8
cmpch8fca00rehkdz8hbidxis	cmp456msw009xhk440hz1q3mu
cmpch8fca00rehkdz8hbidxis	cmp456u0e00bahk44vqbidbz0
cmpch8fca00rehkdz8hbidxis	cmp456zoa00brhk44kp4noqp8
cmpch8fca00rehkdz8hbidxis	cmp4575k400d2hk44wb0llax7
cmpch8fca00rehkdz8hbidxis	cmp457wyq00idhk44pqhw6kmc
cmpch8fca00rehkdz8hbidxis	cmp4588ch00oyhk44scxlin0x
cmpch8fca00rehkdz8hbidxis	cmp458sh600pbhk44o092kiio
cmpxvuq1d00gkhke6xmwxml94	cmp455u3t0064hk44uozb26mm
cmpxvuq1d00gkhke6xmwxml94	cmp456g99009ahk44c8zcwda8
cmpxvuq1d00gkhke6xmwxml94	cmp456msw009xhk440hz1q3mu
cmpxvuq1d00gkhke6xmwxml94	cmp456u0e00bahk44vqbidbz0
cmpxvuq1d00gkhke6xmwxml94	cmp456zoa00brhk44kp4noqp8
cmpxvuq1d00gkhke6xmwxml94	cmp4575k400d2hk44wb0llax7
cmpxvuq1d00gkhke6xmwxml94	cmp457wyq00idhk44pqhw6kmc
cmpxvuq1d00gkhke6xmwxml94	cmp4588ch00oyhk44scxlin0x
cmpxvuq1d00gkhke6xmwxml94	cmp458sh600pbhk44o092kiio
cmpxvuq1d00gkhke6xmwxml94	cmplb4nw30000hkpzwrjyz8fl
cmpxvuq1d00gkhke6xmwxml94	cmpy7fudv01a8hke6voabuhhl
cmpxvii4a00d5hke622cduye0	cmp44zr3i0017hk444oyr7dm3
cmpxvii4a00d5hke622cduye0	cmp455cds003mhk44nkrnvnb8
cmpgmklqk0002hk9karfvcygv	cmp44zr3i0017hk444oyr7dm3
cmpgmklqk0002hk9karfvcygv	cmp455cds003mhk44nkrnvnb8
cmpgmklqk0002hk9karfvcygv	cmp455icp004fhk44v739jonr
cmpgmklqk0002hk9karfvcygv	cmp455u3t0064hk44uozb26mm
cmpgmklqk0002hk9karfvcygv	cmp4569ha008dhk4407omxehu
cmpgmklqk0002hk9karfvcygv	cmp456g99009ahk44c8zcwda8
cmpgmklqk0002hk9karfvcygv	cmp456msw009xhk440hz1q3mu
cmpgmklqk0002hk9karfvcygv	cmp456u0e00bahk44vqbidbz0
cmpgmklqk0002hk9karfvcygv	cmp456zoa00brhk44kp4noqp8
cmpgmklqk0002hk9karfvcygv	cmp4575k400d2hk44wb0llax7
cmpgmklqk0002hk9karfvcygv	cmp457wyq00idhk44pqhw6kmc
cmpgmklqk0002hk9karfvcygv	cmp4588ch00oyhk44scxlin0x
cmpgmklqk0002hk9karfvcygv	cmp458sh600pbhk44o092kiio
cmpgmklqk0002hk9karfvcygv	cmplb4nw30000hkpzwrjyz8fl
cmpgmklqk0002hk9karfvcygv	cmpy7fudv01a8hke6voabuhhl
cmpch8fca00rehkdz8hbidxis	cmplb4nw30000hkpzwrjyz8fl
cmpch8fca00rehkdz8hbidxis	cmpy7fudv01a8hke6voabuhhl
cmp46ome900s3hk44i4eqvhx8	cmp44zr3i0017hk444oyr7dm3
cmp46ome900s3hk44i4eqvhx8	cmp455icp004fhk44v739jonr
cmp46ome900s3hk44i4eqvhx8	cmp455u3t0064hk44uozb26mm
cmp46ome900s3hk44i4eqvhx8	cmp456g99009ahk44c8zcwda8
cmp46ome900s3hk44i4eqvhx8	cmp456msw009xhk440hz1q3mu
cmpcf6a4t005yhkdz4769ze1s	cmp44zr3i0017hk444oyr7dm3
cmpcf6a4t005yhkdz4769ze1s	cmp455icp004fhk44v739jonr
cmpcf6a4t005yhkdz4769ze1s	cmp455u3t0064hk44uozb26mm
cmpcf6a4t005yhkdz4769ze1s	cmp456g99009ahk44c8zcwda8
cmpcf6a4t005yhkdz4769ze1s	cmp456msw009xhk440hz1q3mu
cmpcf6a4t005yhkdz4769ze1s	cmp456u0e00bahk44vqbidbz0
cmpcf6a4t005yhkdz4769ze1s	cmp456zoa00brhk44kp4noqp8
cmpcf6a4t005yhkdz4769ze1s	cmp4575k400d2hk44wb0llax7
cmpcf6a4t005yhkdz4769ze1s	cmp457wyq00idhk44pqhw6kmc
cmpcf6a4t005yhkdz4769ze1s	cmp4588ch00oyhk44scxlin0x
cmpcf6a4t005yhkdz4769ze1s	cmp458sh600pbhk44o092kiio
cmpcf6a4t005yhkdz4769ze1s	cmplb4nw30000hkpzwrjyz8fl
cmpcf6a4t005yhkdz4769ze1s	cmpy7fudv01a8hke6voabuhhl
cmpfbgd4j0002hkzbbn0o1dlo	cmp44zr3i0017hk444oyr7dm3
cmpfbgd4j0002hkzbbn0o1dlo	cmp455cds003mhk44nkrnvnb8
cmpfbgd4j0002hkzbbn0o1dlo	cmp455icp004fhk44v739jonr
cmpfbgd4j0002hkzbbn0o1dlo	cmp455u3t0064hk44uozb26mm
cmpfbgd4j0002hkzbbn0o1dlo	cmp4569ha008dhk4407omxehu
cmpfbgd4j0002hkzbbn0o1dlo	cmp456g99009ahk44c8zcwda8
cmpfbgd4j0002hkzbbn0o1dlo	cmp456msw009xhk440hz1q3mu
cmpfbgd4j0002hkzbbn0o1dlo	cmp456u0e00bahk44vqbidbz0
cmpfbgd4j0002hkzbbn0o1dlo	cmp456zoa00brhk44kp4noqp8
cmpfbgd4j0002hkzbbn0o1dlo	cmp4575k400d2hk44wb0llax7
cmpfbgd4j0002hkzbbn0o1dlo	cmp457wyq00idhk44pqhw6kmc
cmpfbgd4j0002hkzbbn0o1dlo	cmp4588ch00oyhk44scxlin0x
cmpfbgd4j0002hkzbbn0o1dlo	cmp458sh600pbhk44o092kiio
cmpfbgd4j0002hkzbbn0o1dlo	cmplb4nw30000hkpzwrjyz8fl
cmpfbgd4j0002hkzbbn0o1dlo	cmpy7fudv01a8hke6voabuhhl
cmpwswxce0002hkwpttlr7zwx	cmp44zr3i0017hk444oyr7dm3
cmpwswxce0002hkwpttlr7zwx	cmp455cds003mhk44nkrnvnb8
cmpwswxce0002hkwpttlr7zwx	cmp455icp004fhk44v739jonr
cmpwswxce0002hkwpttlr7zwx	cmp455u3t0064hk44uozb26mm
cmpwswxce0002hkwpttlr7zwx	cmp4569ha008dhk4407omxehu
cmpwswxce0002hkwpttlr7zwx	cmp456g99009ahk44c8zcwda8
cmpwswxce0002hkwpttlr7zwx	cmp456msw009xhk440hz1q3mu
cmpwswxce0002hkwpttlr7zwx	cmp456u0e00bahk44vqbidbz0
cmpwswxce0002hkwpttlr7zwx	cmp456zoa00brhk44kp4noqp8
cmpwswxce0002hkwpttlr7zwx	cmp4575k400d2hk44wb0llax7
cmpwswxce0002hkwpttlr7zwx	cmp457wyq00idhk44pqhw6kmc
cmpwswxce0002hkwpttlr7zwx	cmp4588ch00oyhk44scxlin0x
cmpwswxce0002hkwpttlr7zwx	cmp458sh600pbhk44o092kiio
cmpwswxce0002hkwpttlr7zwx	cmplb4nw30000hkpzwrjyz8fl
cmpwswxce0002hkwpttlr7zwx	cmpy7fudv01a8hke6voabuhhl
cmpwtb2xy006uhkwpk9nf103t	cmp44zr3i0017hk444oyr7dm3
cmpwtb2xy006uhkwpk9nf103t	cmp455cds003mhk44nkrnvnb8
cmpwtb2xy006uhkwpk9nf103t	cmp455icp004fhk44v739jonr
cmpwtb2xy006uhkwpk9nf103t	cmp455u3t0064hk44uozb26mm
cmpwtb2xy006uhkwpk9nf103t	cmp4569ha008dhk4407omxehu
cmpwtb2xy006uhkwpk9nf103t	cmp456g99009ahk44c8zcwda8
cmpwtb2xy006uhkwpk9nf103t	cmp456msw009xhk440hz1q3mu
cmpwtb2xy006uhkwpk9nf103t	cmp456u0e00bahk44vqbidbz0
cmpwtb2xy006uhkwpk9nf103t	cmp456zoa00brhk44kp4noqp8
cmpwtb2xy006uhkwpk9nf103t	cmp4575k400d2hk44wb0llax7
cmpwtb2xy006uhkwpk9nf103t	cmp457wyq00idhk44pqhw6kmc
cmp46ome900s3hk44i4eqvhx8	cmp456u0e00bahk44vqbidbz0
cmp46ome900s3hk44i4eqvhx8	cmp456zoa00brhk44kp4noqp8
cmp46ome900s3hk44i4eqvhx8	cmp4575k400d2hk44wb0llax7
cmp46ome900s3hk44i4eqvhx8	cmp457wyq00idhk44pqhw6kmc
cmp46ome900s3hk44i4eqvhx8	cmp4588ch00oyhk44scxlin0x
cmp46ome900s3hk44i4eqvhx8	cmp458sh600pbhk44o092kiio
cmp46ome900s3hk44i4eqvhx8	cmplb4nw30000hkpzwrjyz8fl
cmp46ome900s3hk44i4eqvhx8	cmpy7fudv01a8hke6voabuhhl
cmpcfzz8p00q7hkdzbyqstd86	cmp44zr3i0017hk444oyr7dm3
cmpcfzz8p00q7hkdzbyqstd86	cmp455icp004fhk44v739jonr
cmpcfzz8p00q7hkdzbyqstd86	cmp455u3t0064hk44uozb26mm
cmpcfzz8p00q7hkdzbyqstd86	cmp456g99009ahk44c8zcwda8
cmpcfzz8p00q7hkdzbyqstd86	cmp456msw009xhk440hz1q3mu
cmpcfzz8p00q7hkdzbyqstd86	cmp456u0e00bahk44vqbidbz0
cmpcfzz8p00q7hkdzbyqstd86	cmp456zoa00brhk44kp4noqp8
cmpcfzz8p00q7hkdzbyqstd86	cmp4575k400d2hk44wb0llax7
cmpcfzz8p00q7hkdzbyqstd86	cmp457wyq00idhk44pqhw6kmc
cmpcfzz8p00q7hkdzbyqstd86	cmp4588ch00oyhk44scxlin0x
cmpcfzz8p00q7hkdzbyqstd86	cmp458sh600pbhk44o092kiio
cmpcfzz8p00q7hkdzbyqstd86	cmplb4nw30000hkpzwrjyz8fl
cmpcfzz8p00q7hkdzbyqstd86	cmpy7fudv01a8hke6voabuhhl
cmpfka7qt01xqhkzbwuyum22o	cmp44zr3i0017hk444oyr7dm3
cmpfka7qt01xqhkzbwuyum22o	cmp455cds003mhk44nkrnvnb8
cmpfka7qt01xqhkzbwuyum22o	cmp455icp004fhk44v739jonr
cmpfka7qt01xqhkzbwuyum22o	cmp455u3t0064hk44uozb26mm
cmpfka7qt01xqhkzbwuyum22o	cmp4569ha008dhk4407omxehu
cmpfka7qt01xqhkzbwuyum22o	cmp456g99009ahk44c8zcwda8
cmpfka7qt01xqhkzbwuyum22o	cmp456msw009xhk440hz1q3mu
cmpfka7qt01xqhkzbwuyum22o	cmp456u0e00bahk44vqbidbz0
cmpfka7qt01xqhkzbwuyum22o	cmp456zoa00brhk44kp4noqp8
cmpfka7qt01xqhkzbwuyum22o	cmp4575k400d2hk44wb0llax7
cmpfka7qt01xqhkzbwuyum22o	cmp457wyq00idhk44pqhw6kmc
cmpfka7qt01xqhkzbwuyum22o	cmp4588ch00oyhk44scxlin0x
cmpfka7qt01xqhkzbwuyum22o	cmp458sh600pbhk44o092kiio
cmpfka7qt01xqhkzbwuyum22o	cmplb4nw30000hkpzwrjyz8fl
cmpfka7qt01xqhkzbwuyum22o	cmpy7fudv01a8hke6voabuhhl
cmpcfmqag00bohkdzqj6m6c8w	cmp44zr3i0017hk444oyr7dm3
cmpcfmqag00bohkdzqj6m6c8w	cmp455icp004fhk44v739jonr
cmpcfmqag00bohkdzqj6m6c8w	cmp455u3t0064hk44uozb26mm
cmpcfmqag00bohkdzqj6m6c8w	cmp456g99009ahk44c8zcwda8
cmpcfmqag00bohkdzqj6m6c8w	cmp456msw009xhk440hz1q3mu
cmpcfmqag00bohkdzqj6m6c8w	cmp456u0e00bahk44vqbidbz0
cmpcfmqag00bohkdzqj6m6c8w	cmp456zoa00brhk44kp4noqp8
cmpcfmqag00bohkdzqj6m6c8w	cmp4575k400d2hk44wb0llax7
cmpcfmqag00bohkdzqj6m6c8w	cmp457wyq00idhk44pqhw6kmc
cmpcfmqag00bohkdzqj6m6c8w	cmp4588ch00oyhk44scxlin0x
cmpcfmqag00bohkdzqj6m6c8w	cmp458sh600pbhk44o092kiio
cmpcfmqag00bohkdzqj6m6c8w	cmplb4nw30000hkpzwrjyz8fl
cmpcfmqag00bohkdzqj6m6c8w	cmpy7fudv01a8hke6voabuhhl
cmpwtb2xy006uhkwpk9nf103t	cmp4588ch00oyhk44scxlin0x
cmpwtb2xy006uhkwpk9nf103t	cmp458sh600pbhk44o092kiio
cmpwtb2xy006uhkwpk9nf103t	cmplb4nw30000hkpzwrjyz8fl
cmpwtb2xy006uhkwpk9nf103t	cmpy7fudv01a8hke6voabuhhl
cmpceayuj0002hkdzv7kk1kr6	cmp44zr3i0017hk444oyr7dm3
cmpceayuj0002hkdzv7kk1kr6	cmp455icp004fhk44v739jonr
cmpceayuj0002hkdzv7kk1kr6	cmp455u3t0064hk44uozb26mm
cmpceayuj0002hkdzv7kk1kr6	cmp456g99009ahk44c8zcwda8
cmpceayuj0002hkdzv7kk1kr6	cmp456msw009xhk440hz1q3mu
cmpceayuj0002hkdzv7kk1kr6	cmp456u0e00bahk44vqbidbz0
cmpceayuj0002hkdzv7kk1kr6	cmp456zoa00brhk44kp4noqp8
cmpceayuj0002hkdzv7kk1kr6	cmp4575k400d2hk44wb0llax7
cmpceayuj0002hkdzv7kk1kr6	cmp457wyq00idhk44pqhw6kmc
cmpceayuj0002hkdzv7kk1kr6	cmp4588ch00oyhk44scxlin0x
cmpceayuj0002hkdzv7kk1kr6	cmp458sh600pbhk44o092kiio
cmpceayuj0002hkdzv7kk1kr6	cmplb4nw30000hkpzwrjyz8fl
cmpceayuj0002hkdzv7kk1kr6	cmpy7fudv01a8hke6voabuhhl
cmpceulay004rhkdzau8ylxgo	cmp44zr3i0017hk444oyr7dm3
cmpceulay004rhkdzau8ylxgo	cmp455icp004fhk44v739jonr
cmpxvii4a00d5hke622cduye0	cmp455icp004fhk44v739jonr
cmpxvii4a00d5hke622cduye0	cmp455u3t0064hk44uozb26mm
cmpxvii4a00d5hke622cduye0	cmp4569ha008dhk4407omxehu
cmpxvii4a00d5hke622cduye0	cmp456g99009ahk44c8zcwda8
cmpxvii4a00d5hke622cduye0	cmp456msw009xhk440hz1q3mu
cmpxvii4a00d5hke622cduye0	cmp456u0e00bahk44vqbidbz0
cmpxvii4a00d5hke622cduye0	cmp456zoa00brhk44kp4noqp8
cmpxvii4a00d5hke622cduye0	cmp4575k400d2hk44wb0llax7
cmpxvii4a00d5hke622cduye0	cmp457wyq00idhk44pqhw6kmc
cmpxvii4a00d5hke622cduye0	cmp4588ch00oyhk44scxlin0x
cmpxvii4a00d5hke622cduye0	cmp458sh600pbhk44o092kiio
cmpxvii4a00d5hke622cduye0	cmplb4nw30000hkpzwrjyz8fl
cmpxvii4a00d5hke622cduye0	cmpy7fudv01a8hke6voabuhhl
cmpxvbycp00bxhke63m7149iv	cmp44zr3i0017hk444oyr7dm3
cmpxvbycp00bxhke63m7149iv	cmp455icp004fhk44v739jonr
cmpxvbycp00bxhke63m7149iv	cmp455u3t0064hk44uozb26mm
cmpxvbycp00bxhke63m7149iv	cmp456g99009ahk44c8zcwda8
cmpxvbycp00bxhke63m7149iv	cmp456msw009xhk440hz1q3mu
cmpxvbycp00bxhke63m7149iv	cmp456u0e00bahk44vqbidbz0
cmpxvbycp00bxhke63m7149iv	cmp456zoa00brhk44kp4noqp8
cmpxvbycp00bxhke63m7149iv	cmp4575k400d2hk44wb0llax7
cmpxvbycp00bxhke63m7149iv	cmp457wyq00idhk44pqhw6kmc
cmpxvbycp00bxhke63m7149iv	cmp4588ch00oyhk44scxlin0x
cmpxvbycp00bxhke63m7149iv	cmp458sh600pbhk44o092kiio
cmpceulay004rhkdzau8ylxgo	cmp455u3t0064hk44uozb26mm
cmpceulay004rhkdzau8ylxgo	cmp456g99009ahk44c8zcwda8
cmpceulay004rhkdzau8ylxgo	cmp456msw009xhk440hz1q3mu
cmpceulay004rhkdzau8ylxgo	cmp456u0e00bahk44vqbidbz0
cmpceulay004rhkdzau8ylxgo	cmp456zoa00brhk44kp4noqp8
cmpceulay004rhkdzau8ylxgo	cmp4575k400d2hk44wb0llax7
cmpceulay004rhkdzau8ylxgo	cmp457wyq00idhk44pqhw6kmc
cmpceulay004rhkdzau8ylxgo	cmp4588ch00oyhk44scxlin0x
cmpceulay004rhkdzau8ylxgo	cmp458sh600pbhk44o092kiio
cmpceulay004rhkdzau8ylxgo	cmplb4nw30000hkpzwrjyz8fl
cmpceulay004rhkdzau8ylxgo	cmpy7fudv01a8hke6voabuhhl
cmpxvbycp00bxhke63m7149iv	cmplb4nw30000hkpzwrjyz8fl
cmpxvbycp00bxhke63m7149iv	cmpy7fudv01a8hke6voabuhhl
cmpfexe0c01puhkzb3pkg2qkg	cmp44zr3i0017hk444oyr7dm3
cmpfexe0c01puhkzb3pkg2qkg	cmp455cds003mhk44nkrnvnb8
cmpfexe0c01puhkzb3pkg2qkg	cmp455icp004fhk44v739jonr
cmpfexe0c01puhkzb3pkg2qkg	cmp455u3t0064hk44uozb26mm
cmpfexe0c01puhkzb3pkg2qkg	cmp4569ha008dhk4407omxehu
cmpfexe0c01puhkzb3pkg2qkg	cmp456g99009ahk44c8zcwda8
cmpfexe0c01puhkzb3pkg2qkg	cmp456msw009xhk440hz1q3mu
cmpfexe0c01puhkzb3pkg2qkg	cmp456u0e00bahk44vqbidbz0
cmpfexe0c01puhkzb3pkg2qkg	cmp456zoa00brhk44kp4noqp8
cmpfexe0c01puhkzb3pkg2qkg	cmp4575k400d2hk44wb0llax7
cmpfexe0c01puhkzb3pkg2qkg	cmp457wyq00idhk44pqhw6kmc
cmpfexe0c01puhkzb3pkg2qkg	cmp4588ch00oyhk44scxlin0x
cmpfexe0c01puhkzb3pkg2qkg	cmp458sh600pbhk44o092kiio
cmpfexe0c01puhkzb3pkg2qkg	cmplb4nw30000hkpzwrjyz8fl
cmpfexe0c01puhkzb3pkg2qkg	cmpy7fudv01a8hke6voabuhhl
cmpwv00t600g6hkwpdimacnkh	cmp44zr3i0017hk444oyr7dm3
cmpwv00t600g6hkwpdimacnkh	cmp455cds003mhk44nkrnvnb8
cmpwv00t600g6hkwpdimacnkh	cmp455icp004fhk44v739jonr
cmpwv00t600g6hkwpdimacnkh	cmp455u3t0064hk44uozb26mm
cmpwv00t600g6hkwpdimacnkh	cmp4569ha008dhk4407omxehu
cmpwv00t600g6hkwpdimacnkh	cmp456g99009ahk44c8zcwda8
cmpwv00t600g6hkwpdimacnkh	cmp456msw009xhk440hz1q3mu
cmpwv00t600g6hkwpdimacnkh	cmp456u0e00bahk44vqbidbz0
cmpwv00t600g6hkwpdimacnkh	cmp456zoa00brhk44kp4noqp8
cmpwv00t600g6hkwpdimacnkh	cmp4575k400d2hk44wb0llax7
cmpwv00t600g6hkwpdimacnkh	cmp457wyq00idhk44pqhw6kmc
cmpwv00t600g6hkwpdimacnkh	cmp4588ch00oyhk44scxlin0x
cmpwv00t600g6hkwpdimacnkh	cmp458sh600pbhk44o092kiio
cmpwv00t600g6hkwpdimacnkh	cmplb4nw30000hkpzwrjyz8fl
cmpwv00t600g6hkwpdimacnkh	cmpy7fudv01a8hke6voabuhhl
cmpxwaxx600sdhke69schfi8y	cmplb4nw30000hkpzwrjyz8fl
cmpxwaxx600sdhke69schfi8y	cmpy7fudv01a8hke6voabuhhl
cmpxumqvw00aqhke6ocrgteiz	cmp44zr3i0017hk444oyr7dm3
cmpxumqvw00aqhke6ocrgteiz	cmp455icp004fhk44v739jonr
cmpxumqvw00aqhke6ocrgteiz	cmp455u3t0064hk44uozb26mm
cmpxumqvw00aqhke6ocrgteiz	cmp456g99009ahk44c8zcwda8
cmpxumqvw00aqhke6ocrgteiz	cmp456msw009xhk440hz1q3mu
cmpxumqvw00aqhke6ocrgteiz	cmp456u0e00bahk44vqbidbz0
cmpxumqvw00aqhke6ocrgteiz	cmp456zoa00brhk44kp4noqp8
cmpxumqvw00aqhke6ocrgteiz	cmp4575k400d2hk44wb0llax7
cmpxumqvw00aqhke6ocrgteiz	cmp457wyq00idhk44pqhw6kmc
cmpxumqvw00aqhke6ocrgteiz	cmp4588ch00oyhk44scxlin0x
cmpxumqvw00aqhke6ocrgteiz	cmp458sh600pbhk44o092kiio
cmpxumqvw00aqhke6ocrgteiz	cmplb4nw30000hkpzwrjyz8fl
cmpxumqvw00aqhke6ocrgteiz	cmpy7fudv01a8hke6voabuhhl
cmpcemfd9003khkdzydlfo0v9	cmp44zr3i0017hk444oyr7dm3
cmpcemfd9003khkdzydlfo0v9	cmp455icp004fhk44v739jonr
cmpcemfd9003khkdzydlfo0v9	cmp455u3t0064hk44uozb26mm
cmpcemfd9003khkdzydlfo0v9	cmp456g99009ahk44c8zcwda8
cmpcemfd9003khkdzydlfo0v9	cmp456msw009xhk440hz1q3mu
cmpcemfd9003khkdzydlfo0v9	cmp456u0e00bahk44vqbidbz0
cmpcemfd9003khkdzydlfo0v9	cmp456zoa00brhk44kp4noqp8
cmpcemfd9003khkdzydlfo0v9	cmp4575k400d2hk44wb0llax7
cmpcemfd9003khkdzydlfo0v9	cmp457wyq00idhk44pqhw6kmc
cmpcemfd9003khkdzydlfo0v9	cmp4588ch00oyhk44scxlin0x
cmpcemfd9003khkdzydlfo0v9	cmp458sh600pbhk44o092kiio
cmpcemfd9003khkdzydlfo0v9	cmplb4nw30000hkpzwrjyz8fl
cmpcemfd9003khkdzydlfo0v9	cmpy7fudv01a8hke6voabuhhl
cmpxu82qi008chke6zpw3f0ll	cmp44zr3i0017hk444oyr7dm3
cmpxu82qi008chke6zpw3f0ll	cmp455icp004fhk44v739jonr
cmpxu82qi008chke6zpw3f0ll	cmp455u3t0064hk44uozb26mm
cmpxu82qi008chke6zpw3f0ll	cmp456g99009ahk44c8zcwda8
cmpxu82qi008chke6zpw3f0ll	cmp456msw009xhk440hz1q3mu
cmpxu82qi008chke6zpw3f0ll	cmp456u0e00bahk44vqbidbz0
cmpxu82qi008chke6zpw3f0ll	cmp456zoa00brhk44kp4noqp8
cmpxu82qi008chke6zpw3f0ll	cmp4575k400d2hk44wb0llax7
cmpxu82qi008chke6zpw3f0ll	cmp457wyq00idhk44pqhw6kmc
cmpxu82qi008chke6zpw3f0ll	cmp4588ch00oyhk44scxlin0x
cmpxu82qi008chke6zpw3f0ll	cmp458sh600pbhk44o092kiio
cmpxu82qi008chke6zpw3f0ll	cmplb4nw30000hkpzwrjyz8fl
cmpxu82qi008chke6zpw3f0ll	cmpy7fudv01a8hke6voabuhhl
cmpxtxasu004xhke6zparbgm5	cmp44zr3i0017hk444oyr7dm3
cmpxtxasu004xhke6zparbgm5	cmp455cds003mhk44nkrnvnb8
cmpxtxasu004xhke6zparbgm5	cmp455icp004fhk44v739jonr
cmpxtxasu004xhke6zparbgm5	cmp455u3t0064hk44uozb26mm
cmpxtxasu004xhke6zparbgm5	cmp4569ha008dhk4407omxehu
cmpxtxasu004xhke6zparbgm5	cmp456g99009ahk44c8zcwda8
cmpxtxasu004xhke6zparbgm5	cmp456msw009xhk440hz1q3mu
cmpxtxasu004xhke6zparbgm5	cmp456u0e00bahk44vqbidbz0
cmpxtxasu004xhke6zparbgm5	cmp456zoa00brhk44kp4noqp8
cmpxtxasu004xhke6zparbgm5	cmp4575k400d2hk44wb0llax7
cmpxtxasu004xhke6zparbgm5	cmp457wyq00idhk44pqhw6kmc
cmpxtxasu004xhke6zparbgm5	cmp4588ch00oyhk44scxlin0x
cmpxtxasu004xhke6zparbgm5	cmp458sh600pbhk44o092kiio
cmpxtxasu004xhke6zparbgm5	cmplb4nw30000hkpzwrjyz8fl
cmpxtxasu004xhke6zparbgm5	cmpy7fudv01a8hke6voabuhhl
cmpxui50s009jhke63ury65bc	cmp44zr3i0017hk444oyr7dm3
cmpxui50s009jhke63ury65bc	cmp455icp004fhk44v739jonr
cmpxui50s009jhke63ury65bc	cmp455u3t0064hk44uozb26mm
cmpxui50s009jhke63ury65bc	cmp456g99009ahk44c8zcwda8
cmpxui50s009jhke63ury65bc	cmp456msw009xhk440hz1q3mu
cmpxui50s009jhke63ury65bc	cmp456u0e00bahk44vqbidbz0
cmpxui50s009jhke63ury65bc	cmp456zoa00brhk44kp4noqp8
cmpxui50s009jhke63ury65bc	cmp4575k400d2hk44wb0llax7
cmpxui50s009jhke63ury65bc	cmp457wyq00idhk44pqhw6kmc
cmpxui50s009jhke63ury65bc	cmp4588ch00oyhk44scxlin0x
cmpxui50s009jhke63ury65bc	cmp458sh600pbhk44o092kiio
cmpxui50s009jhke63ury65bc	cmplb4nw30000hkpzwrjyz8fl
cmpxui50s009jhke63ury65bc	cmpy7fudv01a8hke6voabuhhl
\.


--
-- Data for Name: _UserGroups; Type: TABLE DATA; Schema: public; Owner: sinavsistemi_admin
--

COPY public."_UserGroups" ("A", "B") FROM stdin;
cmp44zr3i0017hk444oyr7dm3	cmp44zr4d0019hk44phwupkpv
cmp44zr3i0017hk444oyr7dm3	cmp44zr5a001bhk44ahj5cxip
cmp44zr3i0017hk444oyr7dm3	cmp44zr5t001dhk44vvbbvq6a
cmp44zr3i0017hk444oyr7dm3	cmp44zr6d001fhk44lyhs44qv
cmp44zr3i0017hk444oyr7dm3	cmp44zr6t001hhk44ywcyd4gi
cmp44zr3i0017hk444oyr7dm3	cmp44zr72001jhk44euy1vdvi
cmp44zr3i0017hk444oyr7dm3	cmp44zr7c001lhk44ck0j45ix
cmp44zr3i0017hk444oyr7dm3	cmp44zr7n001nhk44c69yip6l
cmp44zr3i0017hk444oyr7dm3	cmp44zr80001phk44ungi6mc5
cmp44zr3i0017hk444oyr7dm3	cmp44zr89001rhk441fv84l3k
cmp44zr3i0017hk444oyr7dm3	cmp44zr8j001thk44ri8t9gbx
cmp44zr3i0017hk444oyr7dm3	cmp44zr93001vhk442rpw9ljm
cmp44zr3i0017hk444oyr7dm3	cmp44zr9h001xhk44y6izdsdu
cmp44zr3i0017hk444oyr7dm3	cmp44zr9x001zhk44a59wrwji
cmp44zr3i0017hk444oyr7dm3	cmp44zra80021hk44nt83ehy6
cmp44zr3i0017hk444oyr7dm3	cmp44zrbj0023hk44ocazd1vg
cmp44zr3i0017hk444oyr7dm3	cmp44zrc70025hk44blxoyc8t
cmp44zr3i0017hk444oyr7dm3	cmp44zrcr0027hk44qscf8b89
cmp44zr3i0017hk444oyr7dm3	cmp44zrd50029hk44yltjw8s7
cmp44zr3i0017hk444oyr7dm3	cmp44zrdi002bhk44j1vdb8tz
cmp44zr3i0017hk444oyr7dm3	cmp44zrdp002dhk44y9r7gvbo
cmp44zr3i0017hk444oyr7dm3	cmp44zrdz002fhk44vc7twq9g
cmp44zr3i0017hk444oyr7dm3	cmp44zre7002hhk44ae6zabs1
cmp44zr3i0017hk444oyr7dm3	cmp44zrek002jhk44xby0u97n
cmp44zr3i0017hk444oyr7dm3	cmp44zreq002lhk44xt06cnaq
cmp44zr3i0017hk444oyr7dm3	cmp44zrf1002nhk44bq6010vz
cmp44zr3i0017hk444oyr7dm3	cmp44zrfa002phk44yoxoeefu
cmp44zr3i0017hk444oyr7dm3	cmp44zrfr002rhk44mz7zehpe
cmp44zr3i0017hk444oyr7dm3	cmp44zrg3002thk445kgzv423
cmp44zr3i0017hk444oyr7dm3	cmp44zrkq002vhk44aiodzp1v
cmp44zr3i0017hk444oyr7dm3	cmp44zrl9002xhk44k6mklgtt
cmp44zr3i0017hk444oyr7dm3	cmp44zrli002zhk44fvd1ek3s
cmp44zr3i0017hk444oyr7dm3	cmp44zrlw0031hk44vb4wjkbv
cmp44zr3i0017hk444oyr7dm3	cmp44zrmb0033hk446hb8qr26
cmp44zr3i0017hk444oyr7dm3	cmp44zrml0035hk44fot92nrh
cmp44zr3i0017hk444oyr7dm3	cmp44zrmu0037hk44f9uu451d
cmp44zr3i0017hk444oyr7dm3	cmp44zrn20039hk4493ottktf
cmp44zr3i0017hk444oyr7dm3	cmp44zrnf003bhk44j4d0xwzq
cmp44zr3i0017hk444oyr7dm3	cmp44zrns003dhk443u14q28q
cmp44zr3i0017hk444oyr7dm3	cmp44zro4003fhk44wloxsfc8
cmp44zr3i0017hk444oyr7dm3	cmp44zrok003hhk44zspqml64
cmp44zr3i0017hk444oyr7dm3	cmp44zrow003jhk44gukmimpv
cmp44zr3i0017hk444oyr7dm3	cmp44zrp8003lhk4488w951zj
cmp455cds003mhk44nkrnvnb8	cmp455ced003ohk44csce5dhw
cmp455cds003mhk44nkrnvnb8	cmp455cf4003qhk44muomosvq
cmp455cds003mhk44nkrnvnb8	cmp455cfc003shk44tgxwuw08
cmp455cds003mhk44nkrnvnb8	cmp455cfr003uhk44abp8evow
cmp455cds003mhk44nkrnvnb8	cmp455cga003whk4485tmnhwy
cmp455cds003mhk44nkrnvnb8	cmp455chb003yhk44nrph7mli
cmp455cds003mhk44nkrnvnb8	cmp455chq0042hk442eh63gnu
cmp455cds003mhk44nkrnvnb8	cmp455ci30044hk44f5xo6iuz
cmp455cds003mhk44nkrnvnb8	cmp455cid0046hk445xtk87mj
cmp455cds003mhk44nkrnvnb8	cmp455cip0048hk44gff8wtpy
cmp455cds003mhk44nkrnvnb8	cmp455ciy004ahk44av54c33c
cmp455cds003mhk44nkrnvnb8	cmp455cjd004chk446f866ec5
cmp455cds003mhk44nkrnvnb8	cmp455cjm004ehk44z4avsstp
cmp455icp004fhk44v739jonr	cmp455icz004hhk449ugq3cua
cmp455icp004fhk44v739jonr	cmp455idl004lhk44pf7ddqer
cmp455icp004fhk44v739jonr	cmp455ids004nhk4453pp7c1d
cmp455icp004fhk44v739jonr	cmp455ie3004phk44bw4bzxtm
cmp455icp004fhk44v739jonr	cmp455iee004rhk44twdqi5ny
cmp455icp004fhk44v739jonr	cmp455ieq004thk448vvhx4qc
cmp455icp004fhk44v739jonr	cmp455iey004vhk443uymsxx1
cmp455icp004fhk44v739jonr	cmp455if7004xhk44306s6k2h
cmp455icp004fhk44v739jonr	cmp455ifk004zhk44s9alr4f0
cmp455icp004fhk44v739jonr	cmp455ift0051hk445p3xoy6h
cmp455icp004fhk44v739jonr	cmp455ig20053hk44k9wxf531
cmp455icp004fhk44v739jonr	cmp455igd0055hk446m8i9kst
cmp455icp004fhk44v739jonr	cmp455igz0057hk44cltzi3f0
cmp455icp004fhk44v739jonr	cmp455ih70059hk44d64fv786
cmp455icp004fhk44v739jonr	cmp455ihi005bhk44qr5ms59y
cmp455icp004fhk44v739jonr	cmp455ihs005dhk44fd2kst0m
cmp455icp004fhk44v739jonr	cmp455ii5005fhk44bec8axjh
cmp455icp004fhk44v739jonr	cmp455iid005hhk44vc983fnn
cmp455icp004fhk44v739jonr	cmp455iim005jhk44ycu0hqia
cmp455icp004fhk44v739jonr	cmp455iix005lhk4432qi94wv
cmp455icp004fhk44v739jonr	cmp455ij7005nhk446bll5e3d
cmp455icp004fhk44v739jonr	cmp455iji005phk445x421glf
cmp455icp004fhk44v739jonr	cmp455ijy005rhk44p84tg8h7
cmp455icp004fhk44v739jonr	cmp455ik8005thk4483cudk8s
cmp455icp004fhk44v739jonr	cmp455ike005vhk44syyhn57o
cmp455icp004fhk44v739jonr	cmp455ikn005xhk446rhukaux
cmp455icp004fhk44v739jonr	cmp455il0005zhk4413b3ab2n
cmp455icp004fhk44v739jonr	cmp455ilb0061hk4488k8ti9v
cmp455icp004fhk44v739jonr	cmp455ilm0063hk44j84f17dx
cmp455u3t0064hk44uozb26mm	cmp455u4e0066hk44gpptpwde
cmp455u3t0064hk44uozb26mm	cmp455u4x0068hk441ak1bmv3
cmp455u3t0064hk44uozb26mm	cmp455u5a006ahk44ss4yzf1n
cmp455u3t0064hk44uozb26mm	cmp455u5l006chk44h4jay6ur
cmp455u3t0064hk44uozb26mm	cmp455u5w006ehk448tm48uol
cmp455u3t0064hk44uozb26mm	cmp455u69006ghk44bcv12xan
cmp455u3t0064hk44uozb26mm	cmp455u6i006ihk441c6kdpw3
cmp455u3t0064hk44uozb26mm	cmp455u6t006khk44o9r01jaa
cmp455u3t0064hk44uozb26mm	cmp455u71006mhk4453djmd5n
cmp455u3t0064hk44uozb26mm	cmp455u7h006ohk44w8n2hu9w
cmp455u3t0064hk44uozb26mm	cmp455u7w006qhk44jell2pqf
cmp455u3t0064hk44uozb26mm	cmp455u88006shk44ce5bbb6s
cmp455u3t0064hk44uozb26mm	cmp455u8f006uhk44o5kjcxpq
cmp455u3t0064hk44uozb26mm	cmp455u8p006whk44ozm51klj
cmp455u3t0064hk44uozb26mm	cmp455u90006yhk44yqi6yg9f
cmp455u3t0064hk44uozb26mm	cmp455u9f0070hk44hxenb0jf
cmp455u3t0064hk44uozb26mm	cmp455u9m0072hk44g0dgy9pj
cmp455u3t0064hk44uozb26mm	cmp455u9z0074hk44xyqwjo06
cmp455u3t0064hk44uozb26mm	cmp455ua50076hk44vuiu2p74
cmp455u3t0064hk44uozb26mm	cmp455ub1007chk440wvoccju
cmp455u3t0064hk44uozb26mm	cmp455uba007ehk44uhw7tvjk
cmp455u3t0064hk44uozb26mm	cmp455ubj007ghk44xg1kdbn5
cmp455u3t0064hk44uozb26mm	cmp455ubv007ihk44mzhp1oah
cmp455u3t0064hk44uozb26mm	cmp455uc4007khk44tr4bgi7c
cmp455u3t0064hk44uozb26mm	cmp455ucl007mhk4447lw5dnq
cmp455u3t0064hk44uozb26mm	cmp455ucx007ohk44850l1m1f
cmp455u3t0064hk44uozb26mm	cmp455ud8007qhk44jcy4cpg2
cmp455u3t0064hk44uozb26mm	cmp455udg007shk44eoan26jn
cmp455u3t0064hk44uozb26mm	cmp455udp007uhk44b3rwyag3
cmp455u3t0064hk44uozb26mm	cmp455ue0007whk44icwrx0u5
cmp455u3t0064hk44uozb26mm	cmp455ued007yhk442ma13tco
cmp455u3t0064hk44uozb26mm	cmp455uem0080hk44vfeq6zmb
cmp455u3t0064hk44uozb26mm	cmp455uey0082hk4411pzqpfk
cmp455u3t0064hk44uozb26mm	cmp455uf80084hk445e234com
cmp455u3t0064hk44uozb26mm	cmp455uae0078hk44vp3tobpz
cmp455u3t0064hk44uozb26mm	cmp455uaq007ahk44dy49k063
cmp455u3t0064hk44uozb26mm	cmp455ufo0086hk44c6a72bz0
cmp455u3t0064hk44uozb26mm	cmp455ufw0088hk44qacp6ldt
cmp455u3t0064hk44uozb26mm	cmp455ug8008ahk44u0vsz5jn
cmp455u3t0064hk44uozb26mm	cmp455ugg008chk44c3wg8nk7
cmp4569ha008dhk4407omxehu	cmp4569hu008fhk44ak18dply
cmp4569ha008dhk4407omxehu	cmp4569i6008hhk447ylxsjl0
cmp4569ha008dhk4407omxehu	cmp4569ie008jhk44olhex53y
cmp4569ha008dhk4407omxehu	cmp4569ip008lhk440wz7d7jq
cmp4569ha008dhk4407omxehu	cmp4569j1008nhk44r5iqxnf5
cmp4569ha008dhk4407omxehu	cmp4569ja008phk44n9vzi05x
cmp4569ha008dhk4407omxehu	cmp4569jj008rhk44yeogph9n
cmp4569ha008dhk4407omxehu	cmp4569jt008thk44r29k8ls2
cmp4569ha008dhk4407omxehu	cmp4569k6008vhk44jgsxa9i3
cmp4569ha008dhk4407omxehu	cmp4569kh008xhk44iq6xgc7v
cmp4569ha008dhk4407omxehu	cmp4569kq008zhk44lu3ixhbd
cmp4569ha008dhk4407omxehu	cmp4569l50091hk44gx8bf56e
cmp4569ha008dhk4407omxehu	cmp4569lf0093hk4487tx2s3z
cmp4569ha008dhk4407omxehu	cmp4569ln0095hk44mi185hty
cmp4569ha008dhk4407omxehu	cmp4569lw0097hk44jd98eklr
cmp4569ha008dhk4407omxehu	cmp4569m70099hk44sotsjs9o
cmp456g99009ahk44c8zcwda8	cmp456g9k009chk441uvc7dgd
cmp456g99009ahk44c8zcwda8	cmp456g9w009ehk441i7rwc90
cmp456g99009ahk44c8zcwda8	cmp456ga7009ghk44bbqqmoa4
cmp456g99009ahk44c8zcwda8	cmp456gag009ihk44bm4lenj4
cmp456g99009ahk44c8zcwda8	cmp456gar009khk44luaykxio
cmp456g99009ahk44c8zcwda8	cmp456gb2009mhk445a6r1k0i
cmp456g99009ahk44c8zcwda8	cmp456gbc009ohk442mtv7sf3
cmp456g99009ahk44c8zcwda8	cmp456gbl009qhk44cq11g5eh
cmp456g99009ahk44c8zcwda8	cmp456gbw009shk44filvgrp3
cmp456g99009ahk44c8zcwda8	cmp456gc2009uhk446illv0q5
cmp456g99009ahk44c8zcwda8	cmp456gca009whk44nvx6a43n
cmp456msw009xhk440hz1q3mu	cmp456mtg009zhk445cm633g8
cmp456msw009xhk440hz1q3mu	cmp456mtv00a1hk442kviz47q
cmp456msw009xhk440hz1q3mu	cmp456mu600a3hk44vnsdw6sy
cmp456msw009xhk440hz1q3mu	cmp456mup00a5hk44mfmrl17j
cmp456msw009xhk440hz1q3mu	cmp456mv600a7hk44a9knmcfk
cmp456msw009xhk440hz1q3mu	cmp456mvf00a9hk44zd0a5yz3
cmp456msw009xhk440hz1q3mu	cmp456mwd00abhk44queqhbqm
cmp456msw009xhk440hz1q3mu	cmp456mwp00adhk44xtmr12ss
cmp456msw009xhk440hz1q3mu	cmp456mww00afhk440zs6n60z
cmp456msw009xhk440hz1q3mu	cmp456mxa00ahhk44978z94ud
cmp456msw009xhk440hz1q3mu	cmp456mxh00ajhk44mywkaafq
cmp456msw009xhk440hz1q3mu	cmp456mxr00alhk44ws9w7mxg
cmp456msw009xhk440hz1q3mu	cmp456my300anhk44eg31qkga
cmp456msw009xhk440hz1q3mu	cmp456myi00aphk44iw8w81qp
cmp456msw009xhk440hz1q3mu	cmp456mz700arhk44y4d35nbe
cmp456msw009xhk440hz1q3mu	cmp456mzi00athk44ttv1wp55
cmp456msw009xhk440hz1q3mu	cmp456mzu00avhk442rvlmyur
cmp456msw009xhk440hz1q3mu	cmp456n0200axhk445ju2tl9p
cmp456msw009xhk440hz1q3mu	cmp456n0a00azhk44iqbxdtvp
cmp456msw009xhk440hz1q3mu	cmp456n0l00b1hk44iotdmc86
cmp456msw009xhk440hz1q3mu	cmp456n0u00b3hk44qxzkfden
cmp456msw009xhk440hz1q3mu	cmp456n1200b5hk449sm5u2bw
cmp456msw009xhk440hz1q3mu	cmp456n1c00b7hk44ilrostb4
cmp456msw009xhk440hz1q3mu	cmp456n1l00b9hk44gynenry8
cmp456u0e00bahk44vqbidbz0	cmp456u0w00bchk44ododlpvt
cmp456u0e00bahk44vqbidbz0	cmp456u1e00behk44iq7m9mqo
cmp456u0e00bahk44vqbidbz0	cmp456u2300bghk445imzmfy7
cmp456u0e00bahk44vqbidbz0	cmp456u2h00bihk44tuletcpa
cmp456u0e00bahk44vqbidbz0	cmp456u2z00bkhk441cc0hpk2
cmp456u0e00bahk44vqbidbz0	cmp456u3800bmhk44zvfodw6y
cmp456u0e00bahk44vqbidbz0	cmp456u3o00bohk44wiwyq36a
cmp456u0e00bahk44vqbidbz0	cmp456u4600bqhk44ejjm7p7h
cmp456zoa00brhk44kp4noqp8	cmp456zog00bthk44y04l87d0
cmp456zoa00brhk44kp4noqp8	cmp456zos00bvhk44f4s3s2gl
cmp456zoa00brhk44kp4noqp8	cmp456zp400bxhk44nzqksaxr
cmp456zoa00brhk44kp4noqp8	cmp456zpe00bzhk44hr8zwsk9
cmp456zoa00brhk44kp4noqp8	cmp456zpo00c1hk44zqs3wyq0
cmp456zoa00brhk44kp4noqp8	cmp456zpy00c3hk44wdcs4ev3
cmp456zoa00brhk44kp4noqp8	cmp456zq700c5hk44yy136kp0
cmp456zoa00brhk44kp4noqp8	cmp456zqh00c7hk44oyg5p7wm
cmp456zoa00brhk44kp4noqp8	cmp456zqq00c9hk44u6rfdx2l
cmp456zoa00brhk44kp4noqp8	cmp456zr100cbhk44tng2rl3h
cmp456zoa00brhk44kp4noqp8	cmp456zr700cdhk44xy0rmnmi
cmp456zoa00brhk44kp4noqp8	cmp456zrh00cfhk44m0e6snj5
cmp456zoa00brhk44kp4noqp8	cmp456zs500chhk442fbx2flm
cmp456zoa00brhk44kp4noqp8	cmp456zsj00cjhk44exdphfmf
cmp456zoa00brhk44kp4noqp8	cmp456zsv00clhk44bls7idgo
cmp456zoa00brhk44kp4noqp8	cmp456zta00cnhk4455eb5s20
cmp456zoa00brhk44kp4noqp8	cmp456ztq00cphk44vngwyyms
cmp456zoa00brhk44kp4noqp8	cmp456zu300crhk44men5e0fa
cmp456zoa00brhk44kp4noqp8	cmp456zuc00cthk44lownvbih
cmp456zoa00brhk44kp4noqp8	cmp456zup00cvhk44as4mx10o
cmp456zoa00brhk44kp4noqp8	cmp456zuy00cxhk44rslbb02x
cmp456zoa00brhk44kp4noqp8	cmp456zv800czhk445ybxlf9p
cmp456zoa00brhk44kp4noqp8	cmp456zvg00d1hk44ohkskxiz
cmp4575k400d2hk44wb0llax7	cmp4575kg00d4hk44y2zuolhr
cmp4575k400d2hk44wb0llax7	cmp4575ku00d6hk44lspsh181
cmp4575k400d2hk44wb0llax7	cmp4575la00d8hk44bm17551x
cmp4575k400d2hk44wb0llax7	cmp4575lj00dahk44jyne8vhs
cmp4575k400d2hk44wb0llax7	cmp4575lt00dchk44w73w4cyz
cmp4575k400d2hk44wb0llax7	cmp4575m100dehk442a5o41cc
cmp4575k400d2hk44wb0llax7	cmp4575md00dghk449ngm0mfp
cmp4575k400d2hk44wb0llax7	cmp4575ml00dihk44rbuzuly5
cmp4575k400d2hk44wb0llax7	cmp4575n000dkhk44raxfooif
cmp4575k400d2hk44wb0llax7	cmp4575nd00dmhk44hqq11dd3
cmp4575k400d2hk44wb0llax7	cmp4575nu00dohk445klvq16u
cmp4575k400d2hk44wb0llax7	cmp4575o000dqhk44hmi9ny0s
cmp4575k400d2hk44wb0llax7	cmp4575o700dshk440b43vqva
cmp4575k400d2hk44wb0llax7	cmp4575od00duhk4417z4tlzl
cmp4575k400d2hk44wb0llax7	cmp4575oo00dwhk445fltt4up
cmp4575k400d2hk44wb0llax7	cmp4575ov00dyhk44pekyow2v
cmp4575k400d2hk44wb0llax7	cmp4575p300e0hk441m6oslg0
cmp4575k400d2hk44wb0llax7	cmp4575pc00e2hk446y3o964k
cmp4575k400d2hk44wb0llax7	cmp4575pl00e4hk443126ud3p
cmp4575k400d2hk44wb0llax7	cmp4575q000e6hk44hr12a9q9
cmp4575k400d2hk44wb0llax7	cmp4575qb00e8hk44yz1wno4s
cmp4575k400d2hk44wb0llax7	cmp4575qk00eahk44ta8vxcj1
cmp4575k400d2hk44wb0llax7	cmp4575qr00echk44vxpp6tq5
cmp4575k400d2hk44wb0llax7	cmp4575r000eehk44gs5js3ab
cmp4575k400d2hk44wb0llax7	cmp4575r600eghk441kuvrtag
cmp4575k400d2hk44wb0llax7	cmp4575rj00eihk4485poxp57
cmp4575k400d2hk44wb0llax7	cmp4575rw00ekhk44eam3a04h
cmp4575k400d2hk44wb0llax7	cmp4575s600emhk449vywlw8t
cmp4575k400d2hk44wb0llax7	cmp4575sd00eohk44grd5tw80
cmp4575k400d2hk44wb0llax7	cmp4575sm00eqhk448eafxf3c
cmp4575k400d2hk44wb0llax7	cmp4575sx00eshk44lu92yuae
cmp4575k400d2hk44wb0llax7	cmp4575t700euhk44668u90tr
cmp4575k400d2hk44wb0llax7	cmp4575tj00ewhk44f86rjol8
cmp4575k400d2hk44wb0llax7	cmp4575ts00eyhk44rqoa5r5e
cmp4575k400d2hk44wb0llax7	cmp4575u100f0hk444fjp473j
cmp4575k400d2hk44wb0llax7	cmp4575u700f2hk44uwmtfb5i
cmp4575k400d2hk44wb0llax7	cmp4575ui00f4hk44o8xyh6qv
cmp4575k400d2hk44wb0llax7	cmp4575ut00f6hk44wnvnt02x
cmp4575k400d2hk44wb0llax7	cmp4575v000f8hk44nhk3m67v
cmp4575k400d2hk44wb0llax7	cmp4575ve00fahk44fo3lbrjk
cmp4575k400d2hk44wb0llax7	cmp4575vo00fchk44yxdxybul
cmp4575k400d2hk44wb0llax7	cmp4575vx00fehk447yc3x3yr
cmp4575k400d2hk44wb0llax7	cmp4575w400fghk44aba7ypc3
cmp4575k400d2hk44wb0llax7	cmp4575wc00fihk44gq1e36s2
cmp4575k400d2hk44wb0llax7	cmp4575wo00fkhk44bb4db6ge
cmp4575k400d2hk44wb0llax7	cmp4575wx00fmhk44mvoyhnv5
cmp4575k400d2hk44wb0llax7	cmp4575x600fohk44dbecc296
cmp4575k400d2hk44wb0llax7	cmp4575xf00fqhk440kvujtwf
cmp4575k400d2hk44wb0llax7	cmp4575xn00fshk44cr5haum2
cmp4575k400d2hk44wb0llax7	cmp4575xv00fuhk44nzfyvdk3
cmp4575k400d2hk44wb0llax7	cmp4575y500fwhk449gupljrg
cmp4575k400d2hk44wb0llax7	cmp4575yg00fyhk441bdf24xn
cmp4575k400d2hk44wb0llax7	cmp4575ys00g0hk449ds932jq
cmp4575k400d2hk44wb0llax7	cmp4575z600g2hk443d792kld
cmp4575k400d2hk44wb0llax7	cmp4575zd00g4hk44i8vwfzu1
cmp4575k400d2hk44wb0llax7	cmp4575zn00g6hk44dxgs6qdi
cmp4575k400d2hk44wb0llax7	cmp4575zz00g8hk445hojf14i
cmp4575k400d2hk44wb0llax7	cmp45760900gahk444m2wdc2v
cmp4575k400d2hk44wb0llax7	cmp45760k00gchk44xk7tyusb
cmp4575k400d2hk44wb0llax7	cmp45760u00gehk44zxhzhj6x
cmp4575k400d2hk44wb0llax7	cmp45760z00gghk44qvm2cibh
cmp4575k400d2hk44wb0llax7	cmp45761b00gihk442lm2a97q
cmp4575k400d2hk44wb0llax7	cmp45761j00gkhk44wnn42pgg
cmp4575k400d2hk44wb0llax7	cmp45761t00gmhk44rj0xj340
cmp4575k400d2hk44wb0llax7	cmp45762400gohk444r5qlhso
cmp4575k400d2hk44wb0llax7	cmp45762c00gqhk44qrzlx042
cmp4575k400d2hk44wb0llax7	cmp45762o00gshk44s73v3qtc
cmp4575k400d2hk44wb0llax7	cmp45763400guhk44uqh24qhf
cmp4575k400d2hk44wb0llax7	cmp45763d00gwhk44u7es49a8
cmp4575k400d2hk44wb0llax7	cmp45763m00gyhk44860gk8x6
cmp4575k400d2hk44wb0llax7	cmp45763w00h0hk44l13a67hc
cmp4575k400d2hk44wb0llax7	cmp45764800h2hk44biejlpja
cmp4575k400d2hk44wb0llax7	cmp45764i00h4hk44dkq85il9
cmp4575k400d2hk44wb0llax7	cmp45764r00h6hk442f4tcij5
cmp4575k400d2hk44wb0llax7	cmp45764y00h8hk44x6n40rjb
cmp4575k400d2hk44wb0llax7	cmp45765a00hahk44y66n9pgx
cmp4575k400d2hk44wb0llax7	cmp45765j00hchk44hcjri6m7
cmp4575k400d2hk44wb0llax7	cmp45766000hehk44cpr6ftgn
cmp4575k400d2hk44wb0llax7	cmp45766b00hghk44t2uueju7
cmp4575k400d2hk44wb0llax7	cmp45766k00hihk44k5vxmbu8
cmp4575k400d2hk44wb0llax7	cmp45766r00hkhk44iq0crnbw
cmp4575k400d2hk44wb0llax7	cmp45767200hmhk445z8dxwwm
cmp4575k400d2hk44wb0llax7	cmp45767800hohk44aswrrab7
cmp4575k400d2hk44wb0llax7	cmp45767m00hqhk442j1vytve
cmp4575k400d2hk44wb0llax7	cmp45767v00hshk44lfjs7z4j
cmp4575k400d2hk44wb0llax7	cmp45768h00huhk4429zvzlod
cmp4575k400d2hk44wb0llax7	cmp45768q00hwhk44mrz0z1le
cmp4575k400d2hk44wb0llax7	cmp45768w00hyhk44o8o66w9x
cmp4575k400d2hk44wb0llax7	cmp45769400i0hk44k4tb5sl2
cmp4575k400d2hk44wb0llax7	cmp45769e00i2hk44o9a4sm7h
cmp4575k400d2hk44wb0llax7	cmp45769l00i4hk44ahmhg8ov
cmp4575k400d2hk44wb0llax7	cmp45769v00i6hk44cs7s576e
cmp4575k400d2hk44wb0llax7	cmp4576aa00i8hk44ewzrauaz
cmp4575k400d2hk44wb0llax7	cmp4576ai00iahk44qhby2pld
cmp4575k400d2hk44wb0llax7	cmp4576aq00ichk442tvnbts4
cmp457wyq00idhk44pqhw6kmc	cmp457wz800ifhk44rvokzoj3
cmp457wyq00idhk44pqhw6kmc	cmp457wzq00ihhk44l8ng56ay
cmp457wyq00idhk44pqhw6kmc	cmp457wzz00ijhk44enen631m
cmp457wyq00idhk44pqhw6kmc	cmp457x0b00ilhk44vbwkjmj6
cmp457wyq00idhk44pqhw6kmc	cmp457x0n00inhk44a3zzb12f
cmp457wyq00idhk44pqhw6kmc	cmp457x0u00iphk44hsojmuot
cmp457wyq00idhk44pqhw6kmc	cmp457x1500irhk44izfm17r7
cmp457wyq00idhk44pqhw6kmc	cmp457x1g00ithk44b2ad093e
cmp457wyq00idhk44pqhw6kmc	cmp457x1r00ivhk44t6zzbj0v
cmp457wyq00idhk44pqhw6kmc	cmp457x1z00ixhk44u7wbf0ot
cmp457wyq00idhk44pqhw6kmc	cmp457x2b00izhk442i8nkn8v
cmp457wyq00idhk44pqhw6kmc	cmp457x2m00j1hk44321kw4jc
cmp457wyq00idhk44pqhw6kmc	cmp457x2t00j3hk44ew775hqu
cmp457wyq00idhk44pqhw6kmc	cmp457x3600j5hk44b46dqtz1
cmp457wyq00idhk44pqhw6kmc	cmp457x3g00j7hk44s1ws3cr5
cmp457wyq00idhk44pqhw6kmc	cmp457x3t00j9hk44oaugxd96
cmp457wyq00idhk44pqhw6kmc	cmp457x4600jbhk44nr9qyfan
cmp457wyq00idhk44pqhw6kmc	cmp457x4g00jdhk44iknjeo18
cmp457wyq00idhk44pqhw6kmc	cmp457x4p00jfhk44nca1xnlu
cmp457wyq00idhk44pqhw6kmc	cmp457x5000jhhk441oa8cant
cmp457wyq00idhk44pqhw6kmc	cmp457x5b00jjhk44q6aitfbk
cmp457wyq00idhk44pqhw6kmc	cmp457x5m00jlhk44w5309dh1
cmp457wyq00idhk44pqhw6kmc	cmp457x5w00jnhk447mp9h7v6
cmp457wyq00idhk44pqhw6kmc	cmp457x6900jphk44brbj97q9
cmp457wyq00idhk44pqhw6kmc	cmp457x6i00jrhk44n7elfdes
cmp457wyq00idhk44pqhw6kmc	cmp457x6s00jthk4436sjj060
cmp457wyq00idhk44pqhw6kmc	cmp457x7200jvhk44jvplb8nt
cmp457wyq00idhk44pqhw6kmc	cmp457x7c00jxhk4475e2obm0
cmp457wyq00idhk44pqhw6kmc	cmp457x7m00jzhk4450139c1c
cmp457wyq00idhk44pqhw6kmc	cmp457x7w00k1hk44jpwb2cfa
cmp457wyq00idhk44pqhw6kmc	cmp457x8600k3hk443f8wu54a
cmp457wyq00idhk44pqhw6kmc	cmp457x8f00k5hk44w18egd2v
cmp457wyq00idhk44pqhw6kmc	cmp457x8s00k7hk448cpzvqis
cmp457wyq00idhk44pqhw6kmc	cmp457x8z00k9hk44vjas2xy1
cmp457wyq00idhk44pqhw6kmc	cmp457x9900kbhk44sjyz0nl8
cmp457wyq00idhk44pqhw6kmc	cmp457x9j00kdhk44n3uo50w2
cmp457wyq00idhk44pqhw6kmc	cmp457x9w00kfhk44bha6ga0a
cmp457wyq00idhk44pqhw6kmc	cmp457xa500khhk44rbqil359
cmp457wyq00idhk44pqhw6kmc	cmp457xag00kjhk449kyupzhw
cmp457wyq00idhk44pqhw6kmc	cmp457xap00klhk44fjcl6c5a
cmp457wyq00idhk44pqhw6kmc	cmp457xb100knhk44xrbxdm5n
cmp457wyq00idhk44pqhw6kmc	cmp457xb900kphk447hfqherc
cmp457wyq00idhk44pqhw6kmc	cmp457xbj00krhk44zabt9f07
cmp457wyq00idhk44pqhw6kmc	cmp457xbu00kthk44c0xttcy4
cmp457wyq00idhk44pqhw6kmc	cmp457xc200kvhk44tfzry3tx
cmp457wyq00idhk44pqhw6kmc	cmp457xcc00kxhk44tjzzzgh8
cmp457wyq00idhk44pqhw6kmc	cmp457xcj00kzhk4486l2gi1y
cmp457wyq00idhk44pqhw6kmc	cmp457xcv00l1hk44m196y0yv
cmp457wyq00idhk44pqhw6kmc	cmp457xd100l3hk445yjcw72o
cmp457wyq00idhk44pqhw6kmc	cmp457xdd00l5hk4437inixoj
cmp457wyq00idhk44pqhw6kmc	cmp457xdp00l7hk443pgb13wp
cmp457wyq00idhk44pqhw6kmc	cmp457xdz00l9hk44y7evwi2k
cmp457wyq00idhk44pqhw6kmc	cmp457xe900lbhk44d9y18cen
cmp457wyq00idhk44pqhw6kmc	cmp457xen00ldhk44k17b44uv
cmp457wyq00idhk44pqhw6kmc	cmp457xf100lfhk44ojx4pmih
cmp457wyq00idhk44pqhw6kmc	cmp457xfc00lhhk44rn4l0a8s
cmp457wyq00idhk44pqhw6kmc	cmp457xfm00ljhk441omdtpv7
cmp457wyq00idhk44pqhw6kmc	cmp457xfv00llhk44eomve0he
cmp457wyq00idhk44pqhw6kmc	cmp457xg600lnhk44bkmciiee
cmp457wyq00idhk44pqhw6kmc	cmp457xgi00lphk44624f6nib
cmp457wyq00idhk44pqhw6kmc	cmp457xgu00lrhk44165oz4yl
cmp457wyq00idhk44pqhw6kmc	cmp457xh600lthk44o4n3xtk7
cmp457wyq00idhk44pqhw6kmc	cmp457xhi00lvhk44dwe6vusg
cmp457wyq00idhk44pqhw6kmc	cmp457xhq00lxhk444q7r1rzn
cmp457wyq00idhk44pqhw6kmc	cmp457xi200lzhk44ukmjx4y8
cmp457wyq00idhk44pqhw6kmc	cmp457xic00m1hk44y9llhfv5
cmp457wyq00idhk44pqhw6kmc	cmp457xin00m3hk44nxv7lzjh
cmp457wyq00idhk44pqhw6kmc	cmp457xix00m5hk44bw8fq0xo
cmp457wyq00idhk44pqhw6kmc	cmp457xj600m7hk448i172o2c
cmp457wyq00idhk44pqhw6kmc	cmp457xjj00m9hk44ib7ezqgk
cmp457wyq00idhk44pqhw6kmc	cmp457xjs00mbhk44fowpal84
cmp457wyq00idhk44pqhw6kmc	cmp457xk200mdhk44jewj2jgl
cmp457wyq00idhk44pqhw6kmc	cmp457xka00mfhk44kr3zg31p
cmp457wyq00idhk44pqhw6kmc	cmp457xkj00mhhk443mtbyvkf
cmp457wyq00idhk44pqhw6kmc	cmp457xky00mjhk44kxof19kg
cmp457wyq00idhk44pqhw6kmc	cmp457xlb00mlhk44a95a9jfv
cmp457wyq00idhk44pqhw6kmc	cmp457xlm00mnhk44wkk5tvdb
cmp457wyq00idhk44pqhw6kmc	cmp457xlv00mphk44ttt0zdqf
cmp457wyq00idhk44pqhw6kmc	cmp457xm500mrhk44ddqdrz37
cmp457wyq00idhk44pqhw6kmc	cmp457xme00mthk446kz436fy
cmp457wyq00idhk44pqhw6kmc	cmp457xnn00n1hk445f50zioj
cmp457wyq00idhk44pqhw6kmc	cmp457xoe00n5hk44wjd0ve10
cmp457wyq00idhk44pqhw6kmc	cmp457xp900n7hk4483mqniqc
cmp457wyq00idhk44pqhw6kmc	cmp457xpk00n9hk44s7zrf0or
cmp457wyq00idhk44pqhw6kmc	cmp457xpu00nbhk44ap2st0qe
cmp457wyq00idhk44pqhw6kmc	cmp457xq900ndhk44bh3n1q9c
cmp457wyq00idhk44pqhw6kmc	cmp457xqj00nfhk44ubfvgc6o
cmp457wyq00idhk44pqhw6kmc	cmp457xqt00nhhk44lewfhmv3
cmp457wyq00idhk44pqhw6kmc	cmp457xr300njhk447llnhd4x
cmp457wyq00idhk44pqhw6kmc	cmp457xrd00nlhk44kpzkd4l8
cmp457wyq00idhk44pqhw6kmc	cmp457xro00nnhk443t3keilk
cmp457wyq00idhk44pqhw6kmc	cmp457xs800nphk44eg9nx38z
cmp457wyq00idhk44pqhw6kmc	cmp457xsg00nrhk446cl3mjky
cmp457wyq00idhk44pqhw6kmc	cmp457xsp00nthk44d97rz9uw
cmp457wyq00idhk44pqhw6kmc	cmp457xsz00nvhk44c2pzqe83
cmp457wyq00idhk44pqhw6kmc	cmp457xt900nxhk44k9u6mqte
cmp457wyq00idhk44pqhw6kmc	cmp457xtl00nzhk441297jkbw
cmp457wyq00idhk44pqhw6kmc	cmp457xtu00o1hk44di1ec4ys
cmp457wyq00idhk44pqhw6kmc	cmp457xu900o3hk44g9kq70zz
cmp457wyq00idhk44pqhw6kmc	cmp457xvx00ofhk440r539hp9
cmp457wyq00idhk44pqhw6kmc	cmp457xwa00ohhk448oupao7i
cmp457wyq00idhk44pqhw6kmc	cmp457xwm00ojhk44lkts0vo7
cmp457wyq00idhk44pqhw6kmc	cmp457xwu00olhk44yv9xzpy0
cmp457wyq00idhk44pqhw6kmc	cmp457xx400onhk44eor85wxp
cmp457wyq00idhk44pqhw6kmc	cmp457xxf00ophk444sdc74ft
cmp457wyq00idhk44pqhw6kmc	cmp457xxq00orhk44l1euv87j
cmp457wyq00idhk44pqhw6kmc	cmp457xy400othk44zyvgl2mb
cmp457wyq00idhk44pqhw6kmc	cmp457xyf00ovhk44y3z0hk8l
cmp4588ch00oyhk44scxlin0x	cmp4588cr00p0hk44boqdddzd
cmp4588ch00oyhk44scxlin0x	cmp4588d300p2hk44k3r3w4rd
cmp4588ch00oyhk44scxlin0x	cmp4588de00p4hk44u90e49g7
cmp4588ch00oyhk44scxlin0x	cmp4588dz00p8hk44ubkxxc9y
cmp4588ch00oyhk44scxlin0x	cmp4588e800pahk448s1cri1e
cmp457wyq00idhk44pqhw6kmc	cmp457xmq00mvhk44zhntusqt
cmp457wyq00idhk44pqhw6kmc	cmp457xn300mxhk44bx8yv7a4
cmp457wyq00idhk44pqhw6kmc	cmp457xnc00mzhk44mz8t0s21
cmp457wyq00idhk44pqhw6kmc	cmp457xnu00n3hk44n9zjoxm9
cmp457wyq00idhk44pqhw6kmc	cmp457xui00o5hk44tukd73y2
cmp457wyq00idhk44pqhw6kmc	cmp457xus00o7hk440e3l1mb8
cmp457wyq00idhk44pqhw6kmc	cmp457xv100o9hk44k0q58ia4
cmp457wyq00idhk44pqhw6kmc	cmp457xve00obhk44h0jdcy4l
cmp457wyq00idhk44pqhw6kmc	cmp457xvo00odhk44r80ivvlp
cmp457wyq00idhk44pqhw6kmc	cmp457xyt00oxhk44gi8tteun
cmp4588ch00oyhk44scxlin0x	cmp4588do00p6hk44x0r4iosf
cmp458sh600pbhk44o092kiio	cmp458shf00pdhk44fjxkcpbu
cmp458sh600pbhk44o092kiio	cmp458si000pfhk440yu9he7k
cmp458sh600pbhk44o092kiio	cmp458si600phhk4420x6flx1
cmp458sh600pbhk44o092kiio	cmp458sig00pjhk44wfi3bghd
cmp458sh600pbhk44o092kiio	cmp458sir00plhk44ab9f79uz
cmp458sh600pbhk44o092kiio	cmp458sj000pnhk44uh69oz1a
cmp458sh600pbhk44o092kiio	cmp458sjb00pphk441cr59k4g
cmp455icp004fhk44v739jonr	cmor1ahhf0015hkemtlp0dxba
cmp455icp004fhk44v739jonr	cmp455idb004jhk448w23gcni
cmp456g99009ahk44c8zcwda8	cmpfcq6c000xhhkzbdz8k0oq1
cmplb4nw30000hkpzwrjyz8fl	cmplb4nwo0002hkpzty5en03e
cmplb4nw30000hkpzwrjyz8fl	cmplb4nxh0004hkpzask6p1mr
cmplb4nw30000hkpzwrjyz8fl	cmplb4nxv0006hkpzqqyc5xks
cmplb4nw30000hkpzwrjyz8fl	cmplb4nya0008hkpzrs6biruc
cmplb4nw30000hkpzwrjyz8fl	cmplb4nyn000ahkpzh0hn0eme
cmplb4nw30000hkpzwrjyz8fl	cmplb4nyz000chkpztfbcix43
cmplb4nw30000hkpzwrjyz8fl	cmplb4nzd000ehkpzvj3apbsa
cmplb4nw30000hkpzwrjyz8fl	cmplb4nzq000ghkpznr9eb7a5
cmplb4nw30000hkpzwrjyz8fl	cmplb4o03000ihkpzw9de6erq
cmplb4nw30000hkpzwrjyz8fl	cmplb4o0e000khkpza3e75kv6
cmplb4nw30000hkpzwrjyz8fl	cmplb4o0q000mhkpz99u7snp0
cmplb4nw30000hkpzwrjyz8fl	cmplb4o13000ohkpzgwaftpvn
cmplb4nw30000hkpzwrjyz8fl	cmplb4o1e000qhkpzko9eg0jx
cmplb4nw30000hkpzwrjyz8fl	cmplb4o1w000shkpzxyppo68e
cmplb4nw30000hkpzwrjyz8fl	cmplb4o29000uhkpzrs4am7an
cmplb4nw30000hkpzwrjyz8fl	cmplb4o2j000whkpzl7r9y5a6
cmplb4nw30000hkpzwrjyz8fl	cmplb4o2v000yhkpzo2kxzv0o
cmplb4nw30000hkpzwrjyz8fl	cmplb4o3d0010hkpzxmryokmc
cmplb4nw30000hkpzwrjyz8fl	cmplb4o3t0012hkpzagyekzxe
cmplb4nw30000hkpzwrjyz8fl	cmplb4o440014hkpzvidqsp6w
cmplb4nw30000hkpzwrjyz8fl	cmplb4o4h0016hkpzv3s5wl6a
cmplb4nw30000hkpzwrjyz8fl	cmplb4o4s0018hkpzf756xuzy
cmplb4nw30000hkpzwrjyz8fl	cmplb4o54001ahkpzmrbff3o0
cmplb4nw30000hkpzwrjyz8fl	cmplb4o5e001chkpzya2s9xvo
cmplb4nw30000hkpzwrjyz8fl	cmplb4o5p001ehkpz4f9byzn5
cmplb4nw30000hkpzwrjyz8fl	cmplb4o61001ghkpz5yq53khl
cmplb4nw30000hkpzwrjyz8fl	cmplb4o6f001ihkpzt9kpk285
cmplb4nw30000hkpzwrjyz8fl	cmplb4o6r001khkpz20613usr
cmplb4nw30000hkpzwrjyz8fl	cmplb4o71001mhkpzev65ffgr
cmplb4nw30000hkpzwrjyz8fl	cmplb4o7e001ohkpziw18ft9q
cmplb4nw30000hkpzwrjyz8fl	cmplb4o7p001qhkpz1pvitrzj
cmplb4nw30000hkpzwrjyz8fl	cmplb4o82001shkpz7pg18pvh
cmplb4nw30000hkpzwrjyz8fl	cmplb4o8a001uhkpz330vf17w
cmplb4nw30000hkpzwrjyz8fl	cmplb4o8i001whkpzmlu0hg7i
cmplb4nw30000hkpzwrjyz8fl	cmplb4o8u001yhkpz1i26ik3h
cmplb4nw30000hkpzwrjyz8fl	cmplb4o930020hkpzwo4pnwzx
cmplb4nw30000hkpzwrjyz8fl	cmplb4o9c0022hkpzvo43chiq
cmplb4nw30000hkpzwrjyz8fl	cmplb4o9l0024hkpzpia9xvl3
cmplb4nw30000hkpzwrjyz8fl	cmplb4o9u0026hkpzx47n6b65
cmplb4nw30000hkpzwrjyz8fl	cmplb4oa50028hkpzx6d7unfh
cmplb4nw30000hkpzwrjyz8fl	cmplb4oae002ahkpz2cnde67b
cmplb4nw30000hkpzwrjyz8fl	cmplb4oan002chkpzjhpfzemr
cmplb4nw30000hkpzwrjyz8fl	cmplb4oax002ehkpzpiuzbllk
cmplb4nw30000hkpzwrjyz8fl	cmplb4ob7002ghkpz6mo8cigt
cmplb4nw30000hkpzwrjyz8fl	cmplb4obj002ihkpzvbmi5438
cmplb4nw30000hkpzwrjyz8fl	cmplb4obr002khkpzpgo8nyz1
cmplb4nw30000hkpzwrjyz8fl	cmplb4oby002mhkpz36q6lp8e
cmplb4nw30000hkpzwrjyz8fl	cmplb4oc5002ohkpzh9svct16
cmplb4nw30000hkpzwrjyz8fl	cmplb4ocd002qhkpz37sebi9m
cmplb4nw30000hkpzwrjyz8fl	cmplb4ocm002shkpz6kxxmnqu
cmplb4nw30000hkpzwrjyz8fl	cmplb4oct002uhkpz6f6f3h14
cmplb4nw30000hkpzwrjyz8fl	cmplb4od0002whkpze09glth4
cmplb4nw30000hkpzwrjyz8fl	cmplb4od8002yhkpzlr5a5mvq
cmplb4nw30000hkpzwrjyz8fl	cmplb4odi0030hkpzgg2zcf4o
cmplb4nw30000hkpzwrjyz8fl	cmplb4odr0032hkpz8ampg7j0
cmplb4nw30000hkpzwrjyz8fl	cmplb4oe00034hkpzqhrcr5f3
cmplb4nw30000hkpzwrjyz8fl	cmplb4oeb0036hkpzjqqpqs7h
cmplb4nw30000hkpzwrjyz8fl	cmplb4oek0038hkpzkgbrykps
cmplb4nw30000hkpzwrjyz8fl	cmplb4oew003ahkpzh67sxn9d
cmplb4nw30000hkpzwrjyz8fl	cmplb4of7003chkpz70ckujk2
cmplb4nw30000hkpzwrjyz8fl	cmplb4ofe003ehkpzi9hb7hpx
cmplb4nw30000hkpzwrjyz8fl	cmplb4ofm003ghkpz7gddwor0
cmplb4nw30000hkpzwrjyz8fl	cmplb4ofy003ihkpzyvbov3yh
cmplb4nw30000hkpzwrjyz8fl	cmplb4og8003khkpzbcgt4w58
cmplb4nw30000hkpzwrjyz8fl	cmplb4ogh003mhkpznl363pmd
cmplb4nw30000hkpzwrjyz8fl	cmplb4ogq003ohkpz414ng3nk
cmplb4nw30000hkpzwrjyz8fl	cmplb4ogz003qhkpzqx7a2pvb
cmplb4nw30000hkpzwrjyz8fl	cmplb4oh7003shkpz65rg19er
cmplb4nw30000hkpzwrjyz8fl	cmplb4ohg003uhkpzr373b49e
cmplb4nw30000hkpzwrjyz8fl	cmplb4oho003whkpzup314m20
cmplb4nw30000hkpzwrjyz8fl	cmplb4ohw003yhkpz2rluy3ya
cmplb4nw30000hkpzwrjyz8fl	cmplb4oi40040hkpznaksnq20
cmplb4nw30000hkpzwrjyz8fl	cmplb4oie0042hkpz6sxibwmd
cmplb4nw30000hkpzwrjyz8fl	cmplb4oim0044hkpzxppdhm96
cmplb4nw30000hkpzwrjyz8fl	cmplb4oiz0046hkpzaz7pyqen
cmplb4nw30000hkpzwrjyz8fl	cmplb4oj70048hkpzusqkvlu1
cmplb4nw30000hkpzwrjyz8fl	cmplb4ojh004ahkpzvqsn0wwv
cmplb4nw30000hkpzwrjyz8fl	cmplb4ojp004chkpzjdm6zb81
cmplb4nw30000hkpzwrjyz8fl	cmplb4ojy004ehkpz9uycbiws
cmplb4nw30000hkpzwrjyz8fl	cmplb4ok8004ghkpzphsas049
cmplb4nw30000hkpzwrjyz8fl	cmplb4okg004ihkpzccajslj9
cmplb4nw30000hkpzwrjyz8fl	cmplb4okp004khkpzyti08q1p
cmplb4nw30000hkpzwrjyz8fl	cmplb4ol1004mhkpztxqc1m38
cmplb4nw30000hkpzwrjyz8fl	cmplb4olf004ohkpzroh6d9se
cmplb4nw30000hkpzwrjyz8fl	cmplb4olo004qhkpzbstfsz1x
cmplb4nw30000hkpzwrjyz8fl	cmplb4om6004shkpz34gugrzt
cmplb4nw30000hkpzwrjyz8fl	cmplb4omk004uhkpzn8qicomj
cmplb4nw30000hkpzwrjyz8fl	cmplb4omx004whkpz44t81rvo
cmp456g99009ahk44c8zcwda8	cmplbkfs4004yhkpzqh2qmnt6
cmp4588ch00oyhk44scxlin0x	cmpxr9djd0001hke6djazj2jz
cmp455cds003mhk44nkrnvnb8	cmp455chi0040hk442ski3jjz
cmpy7fudv01a8hke6voabuhhl	cmpy7fueb01aahke6az1sdq59
cmpy7fudv01a8hke6voabuhhl	cmpy7fuf101achke65wkchu9i
cmpy7fudv01a8hke6voabuhhl	cmpy7fufb01aehke62c9pie4l
cmpy7fudv01a8hke6voabuhhl	cmpy7fufn01aghke6kygd4mux
cmpy7fudv01a8hke6voabuhhl	cmpy7fufw01aihke673zcogvy
cmpy7fudv01a8hke6voabuhhl	cmpy7fug501akhke6mkojv0oh
cmpy7fudv01a8hke6voabuhhl	cmpy7fugf01amhke6aeokbiw6
cmpy7fudv01a8hke6voabuhhl	cmpy7fugq01aohke683halslh
cmpy7fudv01a8hke6voabuhhl	cmpy7fuh101aqhke663j43nxu
cmpy7fudv01a8hke6voabuhhl	cmpy7fuhd01ashke67l1oh3e3
cmpy7fudv01a8hke6voabuhhl	cmpy7fuhm01auhke6zbf7424l
cmpy7fudv01a8hke6voabuhhl	cmpy7fuhs01awhke6munzb889
cmpy7fudv01a8hke6voabuhhl	cmpy7fui101ayhke68m0p9lbc
cmpy7fudv01a8hke6voabuhhl	cmpy7fuia01b0hke6wij9vew4
cmpy7fudv01a8hke6voabuhhl	cmpy7fuij01b2hke619bz5wsb
cmpy7fudv01a8hke6voabuhhl	cmpy7fuiu01b4hke68iz3262n
cmpy7fudv01a8hke6voabuhhl	cmpy7fuj301b6hke6qkky53za
cmpy7fudv01a8hke6voabuhhl	cmpy7fujd01b8hke6t31vbw8w
cmpy7fudv01a8hke6voabuhhl	cmpy7fujq01bahke6datbstsy
cmpy7fudv01a8hke6voabuhhl	cmpy7fujz01bchke6j52ooj5t
cmpy7fudv01a8hke6voabuhhl	cmpy7fuk901behke64ph75t0q
cmpy7fudv01a8hke6voabuhhl	cmpy7fukl01bghke6jrf8c1d9
cmpy7fudv01a8hke6voabuhhl	cmpy7fuky01bihke6k2ecv9oh
cmpy7fudv01a8hke6voabuhhl	cmpy7fula01bkhke63b6kaox9
cmpy7fudv01a8hke6voabuhhl	cmpy7fulm01bmhke6zfhuvdhb
cmpy7fudv01a8hke6voabuhhl	cmpy7fulz01bohke6ehm65nij
cmpy7fudv01a8hke6voabuhhl	cmpy7fum901bqhke64zf4ke22
cmpy7fudv01a8hke6voabuhhl	cmpy7fumj01bshke6dfzymab2
cmpy7fudv01a8hke6voabuhhl	cmpy7fums01buhke6da8z3fk3
cmpy7fudv01a8hke6voabuhhl	cmpy7fun401bwhke6yd37vaop
cmpy7fudv01a8hke6voabuhhl	cmpy7func01byhke6tp10bv2v
cmpy7fudv01a8hke6voabuhhl	cmpy7funm01c0hke6eflpwyld
cmpy7fudv01a8hke6voabuhhl	cmpy7funw01c2hke6ij02sckx
cmpy7fudv01a8hke6voabuhhl	cmpy7fuo701c4hke6v22cidva
cmpy7fudv01a8hke6voabuhhl	cmpy7fuog01c6hke60v3xcvnb
cmpy7fudv01a8hke6voabuhhl	cmpy7fuos01c8hke6gpngdkcq
cmpy7fudv01a8hke6voabuhhl	cmpy7fup101cahke613y1tnsf
cmpy7fudv01a8hke6voabuhhl	cmpy7fupe01cchke6f4qlepxh
cmpy7fudv01a8hke6voabuhhl	cmpy7fupo01cehke6io7zmqrs
cmpy7fudv01a8hke6voabuhhl	cmpy7fupy01cghke6rkgvkni6
cmpy7fudv01a8hke6voabuhhl	cmpy7fuq701cihke6r9qbm4w7
cmpy7fudv01a8hke6voabuhhl	cmpy7fuqy01ckhke6x2hg2fxp
cmpy7fudv01a8hke6voabuhhl	cmpy7fur701cmhke6h3iwq4lk
cmpy7fudv01a8hke6voabuhhl	cmpy7furj01cohke68n5grhqi
cmpy7fudv01a8hke6voabuhhl	cmpy7furr01cqhke6jc5ujb26
cmpy7fudv01a8hke6voabuhhl	cmpy7fus701cshke6yogw6qtf
cmpy7fudv01a8hke6voabuhhl	cmpy7fusi01cuhke61enpcixt
cmpy7fudv01a8hke6voabuhhl	cmpy7fusv01cwhke6e2mr1jkw
cmpy7fudv01a8hke6voabuhhl	cmpy7fut201cyhke6n24ila1x
cmpy7fudv01a8hke6voabuhhl	cmpy7fute01d0hke61jmiywte
cmpy7fudv01a8hke6voabuhhl	cmpy7futo01d2hke6ckvh11ng
cmpy7fudv01a8hke6voabuhhl	cmpy7futx01d4hke6f18y2akf
cmpy7fudv01a8hke6voabuhhl	cmpy7fuu901d6hke6wps60uh1
cmpy7fudv01a8hke6voabuhhl	cmpy7fuuj01d8hke6edtu5a07
cmpy7fudv01a8hke6voabuhhl	cmpy7fuv001dahke6gha113sj
cmp4588ch00oyhk44scxlin0x	cmq4wllt30001hkoumfx7plz8
cmpy7fudv01a8hke6voabuhhl	cmp1dlkuw0000hkknfm3vhk2s
cmp1dxlwe0003hkkng4uhejav	cmoc4qiu3000csufo75td3z2o
\.


--
-- Data for Name: _prisma_migrations; Type: TABLE DATA; Schema: public; Owner: sinavsistemi_admin
--

COPY public._prisma_migrations (id, checksum, finished_at, migration_name, logs, rolled_back_at, started_at, applied_steps_count) FROM stdin;
5e2d89b5-87ae-47b4-aac2-9fad7d93e2d6	cfcd91c414702ad8e1bb72197d33493ded329b65f85807884064dca70bcbec0b	2026-04-18 16:16:42.923075+00	20260418154643_init	\N	\N	2026-04-18 16:16:42.862461+00	1
fac2beda-3ef8-4e56-92b0-e6ff68ba2b6b	078149add3361b35481830fd09574bc3e89c547f15019ea50fb1188c4bd13120	2026-04-18 16:16:42.94225+00	20260418155009_add_exam_group_relation	\N	\N	2026-04-18 16:16:42.924221+00	1
\.


--
-- Name: Document Document_pkey; Type: CONSTRAINT; Schema: public; Owner: sinavsistemi_admin
--

ALTER TABLE ONLY public."Document"
    ADD CONSTRAINT "Document_pkey" PRIMARY KEY (id);


--
-- Name: ExamPackage ExamPackage_pkey; Type: CONSTRAINT; Schema: public; Owner: sinavsistemi_admin
--

ALTER TABLE ONLY public."ExamPackage"
    ADD CONSTRAINT "ExamPackage_pkey" PRIMARY KEY (id);


--
-- Name: ExamResult ExamResult_pkey; Type: CONSTRAINT; Schema: public; Owner: sinavsistemi_admin
--

ALTER TABLE ONLY public."ExamResult"
    ADD CONSTRAINT "ExamResult_pkey" PRIMARY KEY (id);


--
-- Name: Exam Exam_pkey; Type: CONSTRAINT; Schema: public; Owner: sinavsistemi_admin
--

ALTER TABLE ONLY public."Exam"
    ADD CONSTRAINT "Exam_pkey" PRIMARY KEY (id);


--
-- Name: Group Group_pkey; Type: CONSTRAINT; Schema: public; Owner: sinavsistemi_admin
--

ALTER TABLE ONLY public."Group"
    ADD CONSTRAINT "Group_pkey" PRIMARY KEY (id);


--
-- Name: Institution Institution_pkey; Type: CONSTRAINT; Schema: public; Owner: sinavsistemi_admin
--

ALTER TABLE ONLY public."Institution"
    ADD CONSTRAINT "Institution_pkey" PRIMARY KEY (id);


--
-- Name: PackageResult PackageResult_pkey; Type: CONSTRAINT; Schema: public; Owner: sinavsistemi_admin
--

ALTER TABLE ONLY public."PackageResult"
    ADD CONSTRAINT "PackageResult_pkey" PRIMARY KEY (id);


--
-- Name: QuestionKey QuestionKey_pkey; Type: CONSTRAINT; Schema: public; Owner: sinavsistemi_admin
--

ALTER TABLE ONLY public."QuestionKey"
    ADD CONSTRAINT "QuestionKey_pkey" PRIMARY KEY (id);


--
-- Name: SecurityLog SecurityLog_pkey; Type: CONSTRAINT; Schema: public; Owner: sinavsistemi_admin
--

ALTER TABLE ONLY public."SecurityLog"
    ADD CONSTRAINT "SecurityLog_pkey" PRIMARY KEY (id);


--
-- Name: StudentAnswer StudentAnswer_pkey; Type: CONSTRAINT; Schema: public; Owner: sinavsistemi_admin
--

ALTER TABLE ONLY public."StudentAnswer"
    ADD CONSTRAINT "StudentAnswer_pkey" PRIMARY KEY (id);


--
-- Name: Transaction Transaction_pkey; Type: CONSTRAINT; Schema: public; Owner: sinavsistemi_admin
--

ALTER TABLE ONLY public."Transaction"
    ADD CONSTRAINT "Transaction_pkey" PRIMARY KEY (id);


--
-- Name: User User_pkey; Type: CONSTRAINT; Schema: public; Owner: sinavsistemi_admin
--

ALTER TABLE ONLY public."User"
    ADD CONSTRAINT "User_pkey" PRIMARY KEY (id);


--
-- Name: _DirectExams _DirectExams_AB_pkey; Type: CONSTRAINT; Schema: public; Owner: sinavsistemi_admin
--

ALTER TABLE ONLY public."_DirectExams"
    ADD CONSTRAINT "_DirectExams_AB_pkey" PRIMARY KEY ("A", "B");


--
-- Name: _ExamPackageToGroup _ExamPackageToGroup_AB_pkey; Type: CONSTRAINT; Schema: public; Owner: sinavsistemi_admin
--

ALTER TABLE ONLY public."_ExamPackageToGroup"
    ADD CONSTRAINT "_ExamPackageToGroup_AB_pkey" PRIMARY KEY ("A", "B");


--
-- Name: _ExamToGroup _ExamToGroup_AB_pkey; Type: CONSTRAINT; Schema: public; Owner: sinavsistemi_admin
--

ALTER TABLE ONLY public."_ExamToGroup"
    ADD CONSTRAINT "_ExamToGroup_AB_pkey" PRIMARY KEY ("A", "B");


--
-- Name: _UserGroups _UserGroups_AB_pkey; Type: CONSTRAINT; Schema: public; Owner: sinavsistemi_admin
--

ALTER TABLE ONLY public."_UserGroups"
    ADD CONSTRAINT "_UserGroups_AB_pkey" PRIMARY KEY ("A", "B");


--
-- Name: _prisma_migrations _prisma_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: sinavsistemi_admin
--

ALTER TABLE ONLY public._prisma_migrations
    ADD CONSTRAINT _prisma_migrations_pkey PRIMARY KEY (id);


--
-- Name: Document_createdAt_idx; Type: INDEX; Schema: public; Owner: sinavsistemi_admin
--

CREATE INDEX "Document_createdAt_idx" ON public."Document" USING btree ("createdAt");


--
-- Name: Document_type_idx; Type: INDEX; Schema: public; Owner: sinavsistemi_admin
--

CREATE INDEX "Document_type_idx" ON public."Document" USING btree (type);


--
-- Name: ExamResult_examId_idx; Type: INDEX; Schema: public; Owner: sinavsistemi_admin
--

CREATE INDEX "ExamResult_examId_idx" ON public."ExamResult" USING btree ("examId");


--
-- Name: ExamResult_examId_userId_key; Type: INDEX; Schema: public; Owner: sinavsistemi_admin
--

CREATE UNIQUE INDEX "ExamResult_examId_userId_key" ON public."ExamResult" USING btree ("examId", "userId");


--
-- Name: ExamResult_isFinished_idx; Type: INDEX; Schema: public; Owner: sinavsistemi_admin
--

CREATE INDEX "ExamResult_isFinished_idx" ON public."ExamResult" USING btree ("isFinished");


--
-- Name: ExamResult_userId_idx; Type: INDEX; Schema: public; Owner: sinavsistemi_admin
--

CREATE INDEX "ExamResult_userId_idx" ON public."ExamResult" USING btree ("userId");


--
-- Name: Institution_subdomain_key; Type: INDEX; Schema: public; Owner: sinavsistemi_admin
--

CREATE UNIQUE INDEX "Institution_subdomain_key" ON public."Institution" USING btree (subdomain);


--
-- Name: PackageResult_packageId_userId_key; Type: INDEX; Schema: public; Owner: sinavsistemi_admin
--

CREATE UNIQUE INDEX "PackageResult_packageId_userId_key" ON public."PackageResult" USING btree ("packageId", "userId");


--
-- Name: QuestionKey_examId_questionNumber_key; Type: INDEX; Schema: public; Owner: sinavsistemi_admin
--

CREATE UNIQUE INDEX "QuestionKey_examId_questionNumber_key" ON public."QuestionKey" USING btree ("examId", "questionNumber");


--
-- Name: SecurityLog_actionType_idx; Type: INDEX; Schema: public; Owner: sinavsistemi_admin
--

CREATE INDEX "SecurityLog_actionType_idx" ON public."SecurityLog" USING btree ("actionType");


--
-- Name: SecurityLog_createdAt_idx; Type: INDEX; Schema: public; Owner: sinavsistemi_admin
--

CREATE INDEX "SecurityLog_createdAt_idx" ON public."SecurityLog" USING btree ("createdAt");


--
-- Name: SecurityLog_examId_createdAt_idx; Type: INDEX; Schema: public; Owner: sinavsistemi_admin
--

CREATE INDEX "SecurityLog_examId_createdAt_idx" ON public."SecurityLog" USING btree ("examId", "createdAt");


--
-- Name: SecurityLog_examId_idx; Type: INDEX; Schema: public; Owner: sinavsistemi_admin
--

CREATE INDEX "SecurityLog_examId_idx" ON public."SecurityLog" USING btree ("examId");


--
-- Name: SecurityLog_examId_userId_idx; Type: INDEX; Schema: public; Owner: sinavsistemi_admin
--

CREATE INDEX "SecurityLog_examId_userId_idx" ON public."SecurityLog" USING btree ("examId", "userId");


--
-- Name: SecurityLog_userId_idx; Type: INDEX; Schema: public; Owner: sinavsistemi_admin
--

CREATE INDEX "SecurityLog_userId_idx" ON public."SecurityLog" USING btree ("userId");


--
-- Name: StudentAnswer_resultId_idx; Type: INDEX; Schema: public; Owner: sinavsistemi_admin
--

CREATE INDEX "StudentAnswer_resultId_idx" ON public."StudentAnswer" USING btree ("resultId");


--
-- Name: StudentAnswer_resultId_questionNumber_key; Type: INDEX; Schema: public; Owner: sinavsistemi_admin
--

CREATE UNIQUE INDEX "StudentAnswer_resultId_questionNumber_key" ON public."StudentAnswer" USING btree ("resultId", "questionNumber");


--
-- Name: Transaction_createdAt_idx; Type: INDEX; Schema: public; Owner: sinavsistemi_admin
--

CREATE INDEX "Transaction_createdAt_idx" ON public."Transaction" USING btree ("createdAt");


--
-- Name: Transaction_userId_idx; Type: INDEX; Schema: public; Owner: sinavsistemi_admin
--

CREATE INDEX "Transaction_userId_idx" ON public."Transaction" USING btree ("userId");


--
-- Name: User_email_key; Type: INDEX; Schema: public; Owner: sinavsistemi_admin
--

CREATE UNIQUE INDEX "User_email_key" ON public."User" USING btree (email);


--
-- Name: _DirectExams_B_index; Type: INDEX; Schema: public; Owner: sinavsistemi_admin
--

CREATE INDEX "_DirectExams_B_index" ON public."_DirectExams" USING btree ("B");


--
-- Name: _ExamPackageToGroup_B_index; Type: INDEX; Schema: public; Owner: sinavsistemi_admin
--

CREATE INDEX "_ExamPackageToGroup_B_index" ON public."_ExamPackageToGroup" USING btree ("B");


--
-- Name: _ExamToGroup_B_index; Type: INDEX; Schema: public; Owner: sinavsistemi_admin
--

CREATE INDEX "_ExamToGroup_B_index" ON public."_ExamToGroup" USING btree ("B");


--
-- Name: _UserGroups_B_index; Type: INDEX; Schema: public; Owner: sinavsistemi_admin
--

CREATE INDEX "_UserGroups_B_index" ON public."_UserGroups" USING btree ("B");


--
-- Name: Document Document_institutionId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sinavsistemi_admin
--

ALTER TABLE ONLY public."Document"
    ADD CONSTRAINT "Document_institutionId_fkey" FOREIGN KEY ("institutionId") REFERENCES public."Institution"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: ExamPackage ExamPackage_institutionId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sinavsistemi_admin
--

ALTER TABLE ONLY public."ExamPackage"
    ADD CONSTRAINT "ExamPackage_institutionId_fkey" FOREIGN KEY ("institutionId") REFERENCES public."Institution"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: ExamResult ExamResult_examId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sinavsistemi_admin
--

ALTER TABLE ONLY public."ExamResult"
    ADD CONSTRAINT "ExamResult_examId_fkey" FOREIGN KEY ("examId") REFERENCES public."Exam"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ExamResult ExamResult_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sinavsistemi_admin
--

ALTER TABLE ONLY public."ExamResult"
    ADD CONSTRAINT "ExamResult_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Exam Exam_institutionId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sinavsistemi_admin
--

ALTER TABLE ONLY public."Exam"
    ADD CONSTRAINT "Exam_institutionId_fkey" FOREIGN KEY ("institutionId") REFERENCES public."Institution"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Exam Exam_packageId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sinavsistemi_admin
--

ALTER TABLE ONLY public."Exam"
    ADD CONSTRAINT "Exam_packageId_fkey" FOREIGN KEY ("packageId") REFERENCES public."ExamPackage"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Group Group_institutionId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sinavsistemi_admin
--

ALTER TABLE ONLY public."Group"
    ADD CONSTRAINT "Group_institutionId_fkey" FOREIGN KEY ("institutionId") REFERENCES public."Institution"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Group Group_parentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sinavsistemi_admin
--

ALTER TABLE ONLY public."Group"
    ADD CONSTRAINT "Group_parentId_fkey" FOREIGN KEY ("parentId") REFERENCES public."Group"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: PackageResult PackageResult_packageId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sinavsistemi_admin
--

ALTER TABLE ONLY public."PackageResult"
    ADD CONSTRAINT "PackageResult_packageId_fkey" FOREIGN KEY ("packageId") REFERENCES public."ExamPackage"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: PackageResult PackageResult_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sinavsistemi_admin
--

ALTER TABLE ONLY public."PackageResult"
    ADD CONSTRAINT "PackageResult_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: QuestionKey QuestionKey_examId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sinavsistemi_admin
--

ALTER TABLE ONLY public."QuestionKey"
    ADD CONSTRAINT "QuestionKey_examId_fkey" FOREIGN KEY ("examId") REFERENCES public."Exam"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: SecurityLog SecurityLog_examId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sinavsistemi_admin
--

ALTER TABLE ONLY public."SecurityLog"
    ADD CONSTRAINT "SecurityLog_examId_fkey" FOREIGN KEY ("examId") REFERENCES public."Exam"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: SecurityLog SecurityLog_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sinavsistemi_admin
--

ALTER TABLE ONLY public."SecurityLog"
    ADD CONSTRAINT "SecurityLog_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: StudentAnswer StudentAnswer_resultId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sinavsistemi_admin
--

ALTER TABLE ONLY public."StudentAnswer"
    ADD CONSTRAINT "StudentAnswer_resultId_fkey" FOREIGN KEY ("resultId") REFERENCES public."ExamResult"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Transaction Transaction_institutionId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sinavsistemi_admin
--

ALTER TABLE ONLY public."Transaction"
    ADD CONSTRAINT "Transaction_institutionId_fkey" FOREIGN KEY ("institutionId") REFERENCES public."Institution"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Transaction Transaction_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sinavsistemi_admin
--

ALTER TABLE ONLY public."Transaction"
    ADD CONSTRAINT "Transaction_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: User User_institutionId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sinavsistemi_admin
--

ALTER TABLE ONLY public."User"
    ADD CONSTRAINT "User_institutionId_fkey" FOREIGN KEY ("institutionId") REFERENCES public."Institution"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: _DirectExams _DirectExams_A_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sinavsistemi_admin
--

ALTER TABLE ONLY public."_DirectExams"
    ADD CONSTRAINT "_DirectExams_A_fkey" FOREIGN KEY ("A") REFERENCES public."Exam"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: _DirectExams _DirectExams_B_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sinavsistemi_admin
--

ALTER TABLE ONLY public."_DirectExams"
    ADD CONSTRAINT "_DirectExams_B_fkey" FOREIGN KEY ("B") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: _ExamPackageToGroup _ExamPackageToGroup_A_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sinavsistemi_admin
--

ALTER TABLE ONLY public."_ExamPackageToGroup"
    ADD CONSTRAINT "_ExamPackageToGroup_A_fkey" FOREIGN KEY ("A") REFERENCES public."ExamPackage"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: _ExamPackageToGroup _ExamPackageToGroup_B_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sinavsistemi_admin
--

ALTER TABLE ONLY public."_ExamPackageToGroup"
    ADD CONSTRAINT "_ExamPackageToGroup_B_fkey" FOREIGN KEY ("B") REFERENCES public."Group"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: _ExamToGroup _ExamToGroup_A_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sinavsistemi_admin
--

ALTER TABLE ONLY public."_ExamToGroup"
    ADD CONSTRAINT "_ExamToGroup_A_fkey" FOREIGN KEY ("A") REFERENCES public."Exam"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: _ExamToGroup _ExamToGroup_B_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sinavsistemi_admin
--

ALTER TABLE ONLY public."_ExamToGroup"
    ADD CONSTRAINT "_ExamToGroup_B_fkey" FOREIGN KEY ("B") REFERENCES public."Group"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: _UserGroups _UserGroups_A_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sinavsistemi_admin
--

ALTER TABLE ONLY public."_UserGroups"
    ADD CONSTRAINT "_UserGroups_A_fkey" FOREIGN KEY ("A") REFERENCES public."Group"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: _UserGroups _UserGroups_B_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sinavsistemi_admin
--

ALTER TABLE ONLY public."_UserGroups"
    ADD CONSTRAINT "_UserGroups_B_fkey" FOREIGN KEY ("B") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT CREATE ON SCHEMA public TO kocluk_admin;
GRANT CREATE ON SCHEMA public TO sinavsistemi_admin;


--
-- PostgreSQL database dump complete
--

\unrestrict DqFcUek8DsclYDOSOyaRzc45FcgDPCqMzbFsSD05gmoJbKqm9Dn5fxd2lzFvMLV

