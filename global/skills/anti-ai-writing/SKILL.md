---
name: anti-ai-writing
description: Remove the recognizable LLM signature from a text (any language, any register: report, post, CV, letter, email, landing page, docs). Invoke on "this sounds too AI", "make it human", or before sending any externally-facing text drafted with Claude.
---

# anti-ai-writing

A rewriting doctrine, not a detector. The goal is how a **human reader** perceives the text, not how an automatic detector scores it.

## 1. What this does and does not do

- A reader who recognizes generated prose classifies the document before evaluating it. A good but recognizable text loses more than an average but personal one.
- Commercial detectors measure probability curvature under a reference model, not vocabulary or sentence length. No lexical rule predicts their output reliably.
- Detectors are biased against non-native writers (published work found over half of non-native student essays misclassified as generated). A detector accusation proves nothing, and a clean score guarantees nothing.
- So: this skill orders rewrite priorities. It certifies nothing. If a real stake depends on it (graded submission, application), say so explicitly instead of implying a certified measurement.

## 2. Protocol in 4 steps

| Step | Action | Output |
|---|---|---|
| 1. Diagnose | List the markers found, with weights (table in section 4), register stated | Marker table shown to the user before rewriting |
| 2. Classify | Separate **structural** markers (rhythm, anaphora, colons) from **lexical** ones | Two lists |
| 3. Rewrite | Structure first, lexicon second, never the reverse | Version 2 |
| 4. Re-check | Re-run the diagnosis, aim for no strong marker left | Verdict |

Announce the diagnosis before rewriting. Never do global substitution (`sed` on dashes or a word): each substitution depends on the sentence meaning.

## 3. Six rewrite levers

1. **Replace the abstract with the dated and the figured.** "a transformative experience" becomes "1,900 hours between September and August". A verifiable fact is the one element a model could not produce without knowing it.
2. **Kill the antithesis (expository registers).** "not X, it's Y" is the most visible signature in a note, report or thesis. One per text at most. This inverts in persuasive or emotional writing, where antithesis is a legitimate figure.
3. **Remove meta-commentary.** Any sentence explaining the previous sentence goes ("and that's the point", "what is interesting here"). Keep the argument, drop the commentary. If the argument cannot stand alone, rework the argument.
4. **Purge the stock lexicon** (table below).
5. **Unbalance series (expository registers).** The culprit is regularity, not the number 3. Vary: 2, 4, 5 items.
6. **Break the rhythm and reinject spoken language.** A verbless fragment, a sentence over 30 words, a slightly lopsided turn. Target: a coefficient of variation of sentence lengths above about 0.58. It is the one lever that lexical substitution cannot satisfy, which is why it stays mandatory whatever the rest scores. This is a readability lever, never a detector bypass.

## 4. Marker families

| Family | Weight | Signature | Fix |
|---|---|---|---|
| Antithesis | strong | "is not X. It is Y", "not just X but Y", "it's not about X, it's about Y" | One per text, else assert directly |
| Stock lexicon | strong | delve, leverage, robust, seamless, landscape, realm, testament, underscore, pivotal, crucial, harness, unlock, elevate, tapestry, meticulous, foster, streamline, holistic, cutting-edge, empower, myriad, plethora, paradigm shift, transformative, intricate | The word you would say aloud ("leverage" becomes "use") |
| Meta-commentary | strong | "and that's the point", "here's the thing", "the interesting part is", "let that sink in" | Cut the comment, keep the argument |
| Theatrical pivot | strong | "The answer was:", "one thing became obvious", "and then it clicked" | State the fact |
| Essay connectors | medium | Moreover, Furthermore, Additionally, In conclusion, Ultimately, It's worth noting, At its core | Delete: the next sentence chains without announcing itself |
| Self-assessment | medium | "the best decision I've ever made", "a superpower", "an unfair advantage" | Give the fact, let the reader conclude |
| Hollow intensifier | weak | truly, genuinely, incredibly, arguably, remarkably, deeply | Delete or give the number that justifies it |
| Tidy triplet | weak | "a, b and c" everywhere | Vary the item count |
| Rhythmic uniformity | structural | similar sentence lengths throughout | Add a 3 to 6 word fragment and a 30+ word sentence |
| Constructed anaphora | structural | 2+ sentences opening on the same two words | Keep one |
| Stacked colons | structural | more than 1 colon per 125 words | Turn half into periods or commas |
| Em and en dash | register-dependent | U+2014 and U+2013 as connectors | Comma, period, colon, parentheses. Tolerated in technical docs as markup |

Other languages have their own stock lexicon and the same structural families. Build the list from your own corpus of texts you wrote before using LLMs.

## 5. Never smooth away

- Academic: graded confidence in sources, "reinforced plausibility" versus "validated", disclosure of AI use, explicitly named limits.
- Professional: exact figures, dates, tool and entity names. Replacing them with abstractions "to sound smoother" is the exact opposite error.
- Cut test, all registers: does removing the sentence change what the reader knows? If not, it goes.

## 6. Optional tooling

If you have a marker-density script, run it before and after and compare. Density thresholds should be calibrated on your own human-written controls versus LLM output, with a deliberate bias toward false negatives. A score under threshold means "fewer countable markers", not "does not look like a machine". Rewriting to the score alone (Goodhart) removes only the targeted half of the markers.
