--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.8
-- Dumped by pg_dump version 9.6.8

-- Started on 2018-03-28 22:53:06 EDT

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 679 (class 1247 OID 91900)
-- Name: membership_level; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.membership_level AS ENUM (
    'monthly',
    'annual',
    'lifetime'
);


--
-- TOC entry 784 (class 1247 OID 102164)
-- Name: poll_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.poll_type AS ENUM (
    'inclusion',
    'exclusion'
);


--
-- TOC entry 787 (class 1247 OID 102170)
-- Name: vote; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.vote AS ENUM (
    'in_favor',
    'opposed',
    'abstain'
);


SET default_with_oids = false;

--
-- TOC entry 190 (class 1259 OID 102239)
-- Name: identity; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.identity (
    provider text NOT NULL,
    uid text NOT NULL,
    person text NOT NULL,
    link text,
    picture bytea,
    access_token text NOT NULL,
    expires_at timestamp with time zone
);


--
-- TOC entry 191 (class 1259 OID 102319)
-- Name: membership_ballot; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.membership_ballot (
    poll uuid NOT NULL,
    voter text NOT NULL,
    vote public.vote,
    created timestamp with time zone DEFAULT now() NOT NULL,
    updated timestamp with time zone DEFAULT now() NOT NULL,
    deleted timestamp with time zone
);


--
-- TOC entry 192 (class 1259 OID 102341)
-- Name: membership_poll; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.membership_poll (
    uuid uuid DEFAULT public.gen_random_uuid() NOT NULL,
    type public.poll_type NOT NULL,
    prospect text NOT NULL,
    initiator text NOT NULL,
    created timestamp with time zone DEFAULT now() NOT NULL,
    period tstzrange NOT NULL,
    deleted timestamp with time zone
);


--
-- TOC entry 188 (class 1259 OID 92098)
-- Name: news; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.news (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    title text NOT NULL,
    created timestamp with time zone DEFAULT now() NOT NULL,
    updated timestamp with time zone,
    content text NOT NULL,
    deleted timestamp with time zone,
    published boolean DEFAULT false NOT NULL
);


--
-- TOC entry 189 (class 1259 OID 102233)
-- Name: person; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.person (
    username text NOT NULL,
    display_name text NOT NULL,
    email text NOT NULL,
    locked boolean NOT NULL,
    admin boolean NOT NULL,
    created timestamp with time zone NOT NULL,
    last_login timestamp with time zone,
    stripe_customer_id text,
    notes text
);


--
-- TOC entry 187 (class 1259 OID 91913)
-- Name: stripe_event; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stripe_event (
    id text NOT NULL,
    created timestamp with time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 2675 (class 2606 OID 102285)
-- Name: identity identity_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.identity
    ADD CONSTRAINT identity_pkey PRIMARY KEY (provider, uid);


--
-- TOC entry 2677 (class 2606 OID 102287)
-- Name: identity identity_provider_uid_person_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.identity
    ADD CONSTRAINT identity_provider_uid_person_key UNIQUE (provider, uid, person);


--
-- TOC entry 2681 (class 2606 OID 102328)
-- Name: membership_ballot membership_ballot_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.membership_ballot
    ADD CONSTRAINT membership_ballot_pkey PRIMARY KEY (poll, voter);


--
-- TOC entry 2685 (class 2606 OID 102375)
-- Name: membership_poll membership_poll_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.membership_poll
    ADD CONSTRAINT membership_poll_pkey PRIMARY KEY (uuid);


--
-- TOC entry 2669 (class 2606 OID 92105)
-- Name: news news_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.news
    ADD CONSTRAINT news_pkey PRIMARY KEY (id);


--
-- TOC entry 2671 (class 2606 OID 102291)
-- Name: person person_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.person
    ADD CONSTRAINT person_email_key UNIQUE (email);


--
-- TOC entry 2673 (class 2606 OID 102293)
-- Name: person person_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.person
    ADD CONSTRAINT person_pkey PRIMARY KEY (username);


--
-- TOC entry 2667 (class 2606 OID 91933)
-- Name: stripe_event stripe_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_event
    ADD CONSTRAINT stripe_events_pkey PRIMARY KEY (id);


--
-- TOC entry 2678 (class 1259 OID 102329)
-- Name: fki_membership_ballot_poll_membership_poll_uuid_fkey; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX fki_membership_ballot_poll_membership_poll_uuid_fkey ON public.membership_ballot USING btree (poll);


--
-- TOC entry 2679 (class 1259 OID 102330)
-- Name: fki_membership_ballot_voter_person_username_fkey; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX fki_membership_ballot_voter_person_username_fkey ON public.membership_ballot USING btree (voter);


--
-- TOC entry 2682 (class 1259 OID 102392)
-- Name: fki_membership_poll_initiator_person_username_fkey; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX fki_membership_poll_initiator_person_username_fkey ON public.membership_poll USING btree (initiator);


--
-- TOC entry 2683 (class 1259 OID 102376)
-- Name: fki_membership_poll_prospect_username_fkey; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX fki_membership_poll_prospect_username_fkey ON public.membership_poll USING btree (prospect);


--
-- TOC entry 2686 (class 2606 OID 102297)
-- Name: identity identity_person_person_username_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.identity
    ADD CONSTRAINT identity_person_person_username_fkey FOREIGN KEY (person) REFERENCES public.person(username) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2688 (class 2606 OID 102377)
-- Name: membership_ballot membership_ballot_poll_membership_poll_uuid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.membership_ballot
    ADD CONSTRAINT membership_ballot_poll_membership_poll_uuid_fkey FOREIGN KEY (poll) REFERENCES public.membership_poll(uuid) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2687 (class 2606 OID 102336)
-- Name: membership_ballot membership_ballot_voter_person_username_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.membership_ballot
    ADD CONSTRAINT membership_ballot_voter_person_username_fkey FOREIGN KEY (voter) REFERENCES public.person(username) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2690 (class 2606 OID 102387)
-- Name: membership_poll membership_poll_initiator_person_username_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.membership_poll
    ADD CONSTRAINT membership_poll_initiator_person_username_fkey FOREIGN KEY (initiator) REFERENCES public.person(username) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2689 (class 2606 OID 102382)
-- Name: membership_poll membership_poll_prospect_username_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.membership_poll
    ADD CONSTRAINT membership_poll_prospect_username_fkey FOREIGN KEY (prospect) REFERENCES public.person(username) ON UPDATE CASCADE ON DELETE CASCADE;


-- Completed on 2018-03-28 22:53:06 EDT

--
-- PostgreSQL database dump complete
--

