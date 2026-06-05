--
-- PostgreSQL database dump
--

\restrict U28ZRH584jLmNDCxqPWj4UAU8dWQgqwcw0NHnIYvsfqolRdZGiZyqqZOks6KgA9

-- Dumped from database version 15.15
-- Dumped by pg_dump version 15.15

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
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO postgres;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA public IS '';


--
-- Name: Role; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public."Role" AS ENUM (
    'STUDENT',
    'EDITOR',
    'ADMIN',
    'ASISTAN',
    'SUPERADMIN'
);


ALTER TYPE public."Role" OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: Exam; Type: TABLE; Schema: public; Owner: postgres
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
    "examTemplate" text DEFAULT 'CUSTOM'::text NOT NULL
);


ALTER TABLE public."Exam" OWNER TO postgres;

--
-- Name: ExamResult; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public."ExamResult" OWNER TO postgres;

--
-- Name: Group; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Group" (
    id text NOT NULL,
    name text NOT NULL,
    description text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    code text,
    "expireAt" timestamp(3) without time zone,
    "isActive" boolean DEFAULT true NOT NULL,
    price double precision DEFAULT 0 NOT NULL
);


ALTER TABLE public."Group" OWNER TO postgres;

--
-- Name: QuestionKey; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public."QuestionKey" OWNER TO postgres;

--
-- Name: SecurityLog; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."SecurityLog" (
    id text NOT NULL,
    "examId" text NOT NULL,
    "userId" text NOT NULL,
    "actionType" text NOT NULL,
    details text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."SecurityLog" OWNER TO postgres;

--
-- Name: StudentAnswer; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."StudentAnswer" (
    id text NOT NULL,
    "resultId" text NOT NULL,
    "questionNumber" integer NOT NULL,
    "selectedOption" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."StudentAnswer" OWNER TO postgres;

--
-- Name: Transaction; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Transaction" (
    id text NOT NULL,
    "userId" text NOT NULL,
    amount double precision NOT NULL,
    reason text NOT NULL,
    "groupId" text,
    "examId" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."Transaction" OWNER TO postgres;

--
-- Name: User; Type: TABLE; Schema: public; Owner: postgres
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
    phone text
);


ALTER TABLE public."User" OWNER TO postgres;

--
-- Name: _DirectExams; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."_DirectExams" (
    "A" text NOT NULL,
    "B" text NOT NULL
);


ALTER TABLE public."_DirectExams" OWNER TO postgres;

--
-- Name: _ExamToGroup; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."_ExamToGroup" (
    "A" text NOT NULL,
    "B" text NOT NULL
);


ALTER TABLE public."_ExamToGroup" OWNER TO postgres;

--
-- Name: _UserGroups; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."_UserGroups" (
    "A" text NOT NULL,
    "B" text NOT NULL
);


ALTER TABLE public."_UserGroups" OWNER TO postgres;

--
-- Name: _prisma_migrations; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public._prisma_migrations OWNER TO postgres;

--
-- Data for Name: Exam; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Exam" (id, title, description, "pdfUrl", "solutionPdfUrl", "startTime", "endTime", "showResultsTime", "questionCount", "createdAt", "updatedAt", "isResultsPublished", "virtualTotalParticipants", "baseScore", "penaltyRatio", sections, "durationMinutes", "isActive", "examTemplate") FROM stdin;
cmoc4ptbm0001sufoyim9z9yt	Deneme	Deneme	/uploads/1776987903134-sinav-KPSS-2022-GY-GK-Deneme-1.pdf	/uploads/1776987903139-cozum-KPSS-2022-GY-GK-Deneme-1.pdf	2026-04-23 23:44:00	2026-04-24 23:44:00	2026-04-25 23:44:00	10	2026-04-23 23:45:03.151	2026-04-23 23:49:26.469	t	\N	0	0.25	[{"id": "1776987724202", "count": "10", "title": "Deneme", "points": 1}]	100	t	KPSS_P3
\.


--
-- Data for Name: ExamResult; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."ExamResult" (id, "examId", "userId", score, "correctCount", "wrongCount", "emptyCount", "isFinished", "createdAt", "updatedAt", drawings) FROM stdin;
cmoc4u0ar000zsufo89898zlj	cmoc4ptbm0001sufoyim9z9yt	cmoc4qiu3000csufo75td3z2o	40.875	2	1	7	t	2026-04-23 23:48:18.819	2026-04-23 23:49:04.766	{"1": []}
\.


--
-- Data for Name: Group; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Group" (id, name, description, "createdAt", "updatedAt", code, "expireAt", "isActive", price) FROM stdin;
cmoc4qrye000dsufoonxiycx6	test	Test	2026-04-23 23:45:48.039	2026-04-23 23:45:48.039	Test	\N	t	0
\.


--
-- Data for Name: QuestionKey; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."QuestionKey" (id, "examId", "questionNumber", "correctOption", topic, "createdAt", "updatedAt", points, "videoUrl") FROM stdin;
cmoc4soyi000osufogwqr6v5l	cmoc4ptbm0001sufoyim9z9yt	1	A	Deneme	2026-04-23 23:47:17.467	2026-04-23 23:47:17.467	1	\N
cmoc4soyi000psufob0342wtn	cmoc4ptbm0001sufoyim9z9yt	2	A	Deneme	2026-04-23 23:47:17.467	2026-04-23 23:47:17.467	1	\N
cmoc4soyi000qsufogncsmhj2	cmoc4ptbm0001sufoyim9z9yt	3	A	Deneme	2026-04-23 23:47:17.467	2026-04-23 23:47:17.467	1	\N
cmoc4soyi000rsufohrqrq3d5	cmoc4ptbm0001sufoyim9z9yt	4	A	Deneme	2026-04-23 23:47:17.467	2026-04-23 23:47:17.467	1	\N
cmoc4soyi000ssufoi5r8kh88	cmoc4ptbm0001sufoyim9z9yt	5	A	Deneme	2026-04-23 23:47:17.467	2026-04-23 23:47:17.467	1	\N
cmoc4soyi000tsufosguucfj6	cmoc4ptbm0001sufoyim9z9yt	6	A	Deneme	2026-04-23 23:47:17.467	2026-04-23 23:47:17.467	1	\N
cmoc4soyi000usufo6mjwcm9b	cmoc4ptbm0001sufoyim9z9yt	7	A	Deneme	2026-04-23 23:47:17.467	2026-04-23 23:47:17.467	1	\N
cmoc4soyi000vsufo8tzck8z7	cmoc4ptbm0001sufoyim9z9yt	8	A	Deneme	2026-04-23 23:47:17.467	2026-04-23 23:47:17.467	1	\N
cmoc4soyi000wsufo5mxgxmvf	cmoc4ptbm0001sufoyim9z9yt	9	A	Deneme	2026-04-23 23:47:17.467	2026-04-23 23:47:17.467	1	\N
cmoc4soyi000xsufov4nd9rnf	cmoc4ptbm0001sufoyim9z9yt	10	A	Deneme	2026-04-23 23:47:17.467	2026-04-23 23:47:17.467	1	\N
\.


--
-- Data for Name: SecurityLog; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."SecurityLog" (id, "examId", "userId", "actionType", details, "createdAt") FROM stdin;
cmoc4u7pj0013sufosrv4l5xk	cmoc4ptbm0001sufoyim9z9yt	cmoc4qiu3000csufo75td3z2o	BLUR	Tarayıcı sekmesinden çıkıldı. (Sayfa: 1)	2026-04-23 23:48:28.424
cmoc4u9mf0015suforwrp69jv	cmoc4ptbm0001sufoyim9z9yt	cmoc4qiu3000csufo75td3z2o	BLUR	Tarayıcı sekmesinden çıkıldı. (Sayfa: 1)	2026-04-23 23:48:30.903
cmoc4uk8m0017sufokk6i2hp2	cmoc4ptbm0001sufoyim9z9yt	cmoc4qiu3000csufo75td3z2o	BLUR	Tarayıcı sekmesinden çıkıldı. (Sayfa: 1)	2026-04-23 23:48:44.661
\.


--
-- Data for Name: StudentAnswer; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."StudentAnswer" (id, "resultId", "questionNumber", "selectedOption", "createdAt", "updatedAt") FROM stdin;
cmoc4u37s0011sufoepzdmxag	cmoc4u0ar000zsufo89898zlj	1	A	2026-04-23 23:48:22.6	2026-04-23 23:49:04.703
cmoc4uury001bsufo2u185ibr	cmoc4u0ar000zsufo89898zlj	4	\N	2026-04-23 23:48:58.319	2026-04-23 23:49:04.708
cmoc4utuy0019sufoiekv8pap	cmoc4u0ar000zsufo89898zlj	2	A	2026-04-23 23:48:57.13	2026-04-23 23:49:04.706
cmoc4uveo001dsufozykivloz	cmoc4u0ar000zsufo89898zlj	5	C	2026-04-23 23:48:59.136	2026-04-23 23:49:04.71
\.


--
-- Data for Name: Transaction; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Transaction" (id, "userId", amount, reason, "groupId", "examId", "createdAt") FROM stdin;
\.


--
-- Data for Name: User; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."User" (id, email, password, role, name, "createdAt", "updatedAt", "isActive", phone) FROM stdin;
cmoc1npc70000su98ftbzcgyq	info@on7yazilim.com	on7Admin17!	SUPERADMIN	Super Admin	2026-04-23 22:19:25.832	2026-04-23 22:19:25.832	t	\N
cmoc4l0ya0000sufoei31630p	4takademiankara@gmail.com	4tAdmin.!	ADMIN	4T Akademi	2026-04-23 23:41:19.758	2026-04-23 23:41:19.758	t	05555555555
cmoc4qiu3000csufo75td3z2o	test@test.com	123456	STUDENT	Testogr	2026-04-23 23:45:36.207	2026-04-23 23:45:36.207	t	\N
\.


--
-- Data for Name: _DirectExams; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."_DirectExams" ("A", "B") FROM stdin;
\.


--
-- Data for Name: _ExamToGroup; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."_ExamToGroup" ("A", "B") FROM stdin;
cmoc4ptbm0001sufoyim9z9yt	cmoc4qrye000dsufoonxiycx6
\.


--
-- Data for Name: _UserGroups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."_UserGroups" ("A", "B") FROM stdin;
cmoc4qrye000dsufoonxiycx6	cmoc4qiu3000csufo75td3z2o
\.


--
-- Data for Name: _prisma_migrations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public._prisma_migrations (id, checksum, finished_at, migration_name, logs, rolled_back_at, started_at, applied_steps_count) FROM stdin;
5e2d89b5-87ae-47b4-aac2-9fad7d93e2d6	cfcd91c414702ad8e1bb72197d33493ded329b65f85807884064dca70bcbec0b	2026-04-18 16:16:42.923075+00	20260418154643_init	\N	\N	2026-04-18 16:16:42.862461+00	1
fac2beda-3ef8-4e56-92b0-e6ff68ba2b6b	078149add3361b35481830fd09574bc3e89c547f15019ea50fb1188c4bd13120	2026-04-18 16:16:42.94225+00	20260418155009_add_exam_group_relation	\N	\N	2026-04-18 16:16:42.924221+00	1
\.


--
-- Name: ExamResult ExamResult_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ExamResult"
    ADD CONSTRAINT "ExamResult_pkey" PRIMARY KEY (id);


--
-- Name: Exam Exam_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Exam"
    ADD CONSTRAINT "Exam_pkey" PRIMARY KEY (id);


--
-- Name: Group Group_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Group"
    ADD CONSTRAINT "Group_pkey" PRIMARY KEY (id);


--
-- Name: QuestionKey QuestionKey_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."QuestionKey"
    ADD CONSTRAINT "QuestionKey_pkey" PRIMARY KEY (id);


--
-- Name: SecurityLog SecurityLog_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SecurityLog"
    ADD CONSTRAINT "SecurityLog_pkey" PRIMARY KEY (id);


--
-- Name: StudentAnswer StudentAnswer_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."StudentAnswer"
    ADD CONSTRAINT "StudentAnswer_pkey" PRIMARY KEY (id);


--
-- Name: Transaction Transaction_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Transaction"
    ADD CONSTRAINT "Transaction_pkey" PRIMARY KEY (id);


--
-- Name: User User_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."User"
    ADD CONSTRAINT "User_pkey" PRIMARY KEY (id);


--
-- Name: _DirectExams _DirectExams_AB_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."_DirectExams"
    ADD CONSTRAINT "_DirectExams_AB_pkey" PRIMARY KEY ("A", "B");


--
-- Name: _ExamToGroup _ExamToGroup_AB_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."_ExamToGroup"
    ADD CONSTRAINT "_ExamToGroup_AB_pkey" PRIMARY KEY ("A", "B");


--
-- Name: _UserGroups _UserGroups_AB_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."_UserGroups"
    ADD CONSTRAINT "_UserGroups_AB_pkey" PRIMARY KEY ("A", "B");


--
-- Name: _prisma_migrations _prisma_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public._prisma_migrations
    ADD CONSTRAINT _prisma_migrations_pkey PRIMARY KEY (id);


--
-- Name: ExamResult_examId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ExamResult_examId_idx" ON public."ExamResult" USING btree ("examId");


--
-- Name: ExamResult_examId_userId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "ExamResult_examId_userId_key" ON public."ExamResult" USING btree ("examId", "userId");


--
-- Name: ExamResult_isFinished_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ExamResult_isFinished_idx" ON public."ExamResult" USING btree ("isFinished");


--
-- Name: ExamResult_userId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ExamResult_userId_idx" ON public."ExamResult" USING btree ("userId");


--
-- Name: Group_code_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "Group_code_key" ON public."Group" USING btree (code);


--
-- Name: QuestionKey_examId_questionNumber_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "QuestionKey_examId_questionNumber_key" ON public."QuestionKey" USING btree ("examId", "questionNumber");


--
-- Name: SecurityLog_actionType_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SecurityLog_actionType_idx" ON public."SecurityLog" USING btree ("actionType");


--
-- Name: SecurityLog_createdAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SecurityLog_createdAt_idx" ON public."SecurityLog" USING btree ("createdAt");


--
-- Name: SecurityLog_examId_createdAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SecurityLog_examId_createdAt_idx" ON public."SecurityLog" USING btree ("examId", "createdAt");


--
-- Name: SecurityLog_examId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SecurityLog_examId_idx" ON public."SecurityLog" USING btree ("examId");


--
-- Name: SecurityLog_examId_userId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SecurityLog_examId_userId_idx" ON public."SecurityLog" USING btree ("examId", "userId");


--
-- Name: SecurityLog_userId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "SecurityLog_userId_idx" ON public."SecurityLog" USING btree ("userId");


--
-- Name: StudentAnswer_resultId_questionNumber_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "StudentAnswer_resultId_questionNumber_key" ON public."StudentAnswer" USING btree ("resultId", "questionNumber");


--
-- Name: Transaction_createdAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Transaction_createdAt_idx" ON public."Transaction" USING btree ("createdAt");


--
-- Name: Transaction_userId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "Transaction_userId_idx" ON public."Transaction" USING btree ("userId");


--
-- Name: User_email_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "User_email_key" ON public."User" USING btree (email);


--
-- Name: _DirectExams_B_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "_DirectExams_B_index" ON public."_DirectExams" USING btree ("B");


--
-- Name: _ExamToGroup_B_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "_ExamToGroup_B_index" ON public."_ExamToGroup" USING btree ("B");


--
-- Name: _UserGroups_B_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "_UserGroups_B_index" ON public."_UserGroups" USING btree ("B");


--
-- Name: ExamResult ExamResult_examId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ExamResult"
    ADD CONSTRAINT "ExamResult_examId_fkey" FOREIGN KEY ("examId") REFERENCES public."Exam"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ExamResult ExamResult_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ExamResult"
    ADD CONSTRAINT "ExamResult_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: QuestionKey QuestionKey_examId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."QuestionKey"
    ADD CONSTRAINT "QuestionKey_examId_fkey" FOREIGN KEY ("examId") REFERENCES public."Exam"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: SecurityLog SecurityLog_examId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SecurityLog"
    ADD CONSTRAINT "SecurityLog_examId_fkey" FOREIGN KEY ("examId") REFERENCES public."Exam"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: SecurityLog SecurityLog_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SecurityLog"
    ADD CONSTRAINT "SecurityLog_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: StudentAnswer StudentAnswer_resultId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."StudentAnswer"
    ADD CONSTRAINT "StudentAnswer_resultId_fkey" FOREIGN KEY ("resultId") REFERENCES public."ExamResult"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Transaction Transaction_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Transaction"
    ADD CONSTRAINT "Transaction_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: _DirectExams _DirectExams_A_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."_DirectExams"
    ADD CONSTRAINT "_DirectExams_A_fkey" FOREIGN KEY ("A") REFERENCES public."Exam"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: _DirectExams _DirectExams_B_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."_DirectExams"
    ADD CONSTRAINT "_DirectExams_B_fkey" FOREIGN KEY ("B") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: _ExamToGroup _ExamToGroup_A_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."_ExamToGroup"
    ADD CONSTRAINT "_ExamToGroup_A_fkey" FOREIGN KEY ("A") REFERENCES public."Exam"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: _ExamToGroup _ExamToGroup_B_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."_ExamToGroup"
    ADD CONSTRAINT "_ExamToGroup_B_fkey" FOREIGN KEY ("B") REFERENCES public."Group"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: _UserGroups _UserGroups_A_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."_UserGroups"
    ADD CONSTRAINT "_UserGroups_A_fkey" FOREIGN KEY ("A") REFERENCES public."Group"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: _UserGroups _UserGroups_B_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."_UserGroups"
    ADD CONSTRAINT "_UserGroups_B_fkey" FOREIGN KEY ("B") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;


--
-- PostgreSQL database dump complete
--

\unrestrict U28ZRH584jLmNDCxqPWj4UAU8dWQgqwcw0NHnIYvsfqolRdZGiZyqqZOks6KgA9

