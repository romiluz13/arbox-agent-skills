# Questions for our Arbox contact

We're building a free, public, community set of AI agent skills. They help Arbox customers (studio and gym owners) use Claude Code with their Arbox data: reports, lead follow-up, and drafts for member messages. Every write goes through an owner confirmation. Your answers shape the setup instructions and the safety rules. Short answers are fine, and "don't know" is fine too.

## API access
1. Which plans include API access? Is it on by default, or does the customer have to request it?
2. Where does an owner find the key in the admin (we believe Settings → Business Information)? Which staff roles can see it?
3. Does each branch or location get its own key, or does one key cover every location of a business?
4. What is `location_box_fk`, and when does a customer need to request it from support?
5. Can a key be limited to read-only, or scoped in some other way? Can an owner rotate or revoke it themselves?

## Behavior
6. Rate limits: how many requests per minute or per day?
7. `POST /v3/message`: does it send immediately? Is there a test or "send to myself" mode? Is WhatsApp available only with the Meta integration?
8. Is there a sandbox or demo-business mode beyond a test account?
9. Is `https://arboxserver.arboxapp.com/docs/api.json` the stable, official spec URL that we can point agents to?

## Permission
10. Is it OK for a community project to use the name "Arbox" (e.g. `arbox-agent-skills`) and redistribute content derived from the public API docs? Is there wording you'd like in the README (e.g. "Community project, not affiliated with Arbox")?
11. Would Arbox want to review or co-own this later?
