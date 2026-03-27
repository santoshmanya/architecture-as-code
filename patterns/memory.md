Full blueprint above. Here's the mental model in one pass:
Write path (during chat): MongoDB takes everything — raw turns, hot KV session state, zero schema friction.
Write path (after chat): Async LLM job extracts three typed artifacts — hard facts → PG, preferences → PG with consolidation chain, episodic reflections → Mongo + embedded into pgvector.
Read path (next chat): Embed the incoming query → pgvector cosine search scoped to user_id → pull top-3 memories with dates → merge with PG facts/prefs → inject into system prompt before the user types their first word.
The "we spoke about this on March 14th" pattern lives entirely in pgvector. The session_date comes back with the embedding hit, so the agent can surface it naturally — but only if similarity score clears your threshold (0.82 recommended) to avoid false recalls that would feel creepy or wrong.
Two things to nail in implementation:

The consolidation logic in PG — use the overridden_by FK chain, never hard delete. You want full audit history for enterprise compliance.
The pgvector query must filter by user_id first before cosine scoring. Namespace isolation is your blast radius control in a multi-tenant environment.

Want me to generate the actual SQL migrations, the LLM extraction prompt, or the ADK/FastAPI service skeleton next?
