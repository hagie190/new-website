--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.8
-- Dumped by pg_dump version 9.6.8

-- Started on 2018-03-21 21:14:57 EDT

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


SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 187 (class 1259 OID 91907)
-- Name: identity; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.identity (
    provider text NOT NULL,
    uid text NOT NULL,
    link text,
    picture bytea,
    access_token text NOT NULL,
    expires_at timestamp with time zone,
    person uuid NOT NULL
);


--
-- TOC entry 191 (class 1259 OID 101866)
-- Name: membership_poll; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.membership_poll (
    uuid uuid DEFAULT public.gen_random_uuid() NOT NULL,
    prospect_uuid uuid NOT NULL,
    created timestamp with time zone DEFAULT now() NOT NULL,
    period tstzrange NOT NULL,
    type boolean NOT NULL,
    deleted timestamp with time zone
);


--
-- TOC entry 2806 (class 0 OID 0)
-- Dependencies: 191
-- Name: COLUMN membership_poll.type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.membership_poll.type IS '''true'' for new members (voting to get them in), ''false'' for existing members (voting to kick them out).';


--
-- TOC entry 192 (class 1259 OID 101958)
-- Name: membership_vote; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.membership_vote (
    poll uuid NOT NULL,
    voter uuid NOT NULL,
    vote boolean NOT NULL,
    created timestamp with time zone DEFAULT now() NOT NULL,
    updated timestamp with time zone DEFAULT now() NOT NULL,
    deleted timestamp with time zone
);


--
-- TOC entry 190 (class 1259 OID 92098)
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
-- TOC entry 189 (class 1259 OID 91999)
-- Name: person; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.person (
    display_name text NOT NULL,
    email text NOT NULL,
    locked boolean NOT NULL,
    admin boolean NOT NULL,
    created timestamp with time zone NOT NULL,
    last_login timestamp with time zone,
    stripe_customer_id text,
    notes text,
    uuid uuid DEFAULT public.gen_random_uuid() NOT NULL
);


--
-- TOC entry 188 (class 1259 OID 91913)
-- Name: stripe_event; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stripe_event (
    id text NOT NULL,
    created timestamp with time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 2662 (class 2606 OID 91929)
-- Name: identity identity_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.identity
    ADD CONSTRAINT identity_pkey PRIMARY KEY (provider, uid);


--
-- TOC entry 2664 (class 2606 OID 101661)
-- Name: identity identity_provider_uid_person_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.identity
    ADD CONSTRAINT identity_provider_uid_person_key UNIQUE (provider, uid, person);


--
-- TOC entry 2676 (class 2606 OID 101872)
-- Name: membership_poll membership_poll_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.membership_poll
    ADD CONSTRAINT membership_poll_pkey PRIMARY KEY (uuid);


--
-- TOC entry 2678 (class 2606 OID 102118)
-- Name: membership_vote membership_vote_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.membership_vote
    ADD CONSTRAINT membership_vote_pkey PRIMARY KEY (poll, voter);


--
-- TOC entry 2674 (class 2606 OID 92105)
-- Name: news news_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.news
    ADD CONSTRAINT news_pkey PRIMARY KEY (id);


--
-- TOC entry 2668 (class 2606 OID 101669)
-- Name: person person_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.person
    ADD CONSTRAINT person_email_key UNIQUE (email);


--
-- TOC entry 2670 (class 2606 OID 101659)
-- Name: person person_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.person
    ADD CONSTRAINT person_pkey PRIMARY KEY (uuid);


--
-- TOC entry 2672 (class 2606 OID 101671)
-- Name: person person_stripe_customer_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.person
    ADD CONSTRAINT person_stripe_customer_id_key UNIQUE (stripe_customer_id);


--
-- TOC entry 2666 (class 2606 OID 91933)
-- Name: stripe_event stripe_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stripe_event
    ADD CONSTRAINT stripe_events_pkey PRIMARY KEY (id);


--
-- TOC entry 2660 (class 1259 OID 101667)
-- Name: fki_identity_person_fkey; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX fki_identity_person_fkey ON public.identity USING btree (person);


--
-- TOC entry 2679 (class 2606 OID 101662)
-- Name: identity identity_person_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.identity
    ADD CONSTRAINT identity_person_fkey FOREIGN KEY (person) REFERENCES public.person(uuid) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2680 (class 2606 OID 101873)
-- Name: membership_poll membership_poll_prospect_uuid_person_uuid; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.membership_poll
    ADD CONSTRAINT membership_poll_prospect_uuid_person_uuid FOREIGN KEY (prospect_uuid) REFERENCES public.person(uuid) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2681 (class 2606 OID 101964)
-- Name: membership_vote membership_vote_poll_membership_poll_uuid; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.membership_vote
    ADD CONSTRAINT membership_vote_poll_membership_poll_uuid FOREIGN KEY (poll) REFERENCES public.membership_poll(uuid) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2682 (class 2606 OID 101974)
-- Name: membership_vote membership_vote_voter_person_uuid; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.membership_vote
    ADD CONSTRAINT membership_vote_voter_person_uuid FOREIGN KEY (voter) REFERENCES public.person(uuid);


-- Completed on 2018-03-21 21:14:57 EDT

--
-- PostgreSQL database dump complete
--

