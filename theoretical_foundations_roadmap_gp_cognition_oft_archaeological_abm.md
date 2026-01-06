# Position Paper (Draft)
## Optimal Foraging Under Spatial Uncertainty: Gaussian-Process Cognition in Archaeological Agent-Based Models

### Abstract
Archaeological applications of Optimal Foraging Theory (OFT) have long benefited from the clarity of optimization-based reasoning: if resources, risks, and travel costs are structured in space, foragers should allocate effort in ways that are predictably efficient. Yet the archaeological record is also an archive of **learning**, **partial knowledge**, and **path-dependent discovery**. People rarely act on a fully known landscape; they act on the landscape they *believe* exists, and that belief is shaped by prior experience, social transmission, and constrained observation. This position paper proposes a computational synthesis that makes that distinction explicit. We model prehistoric foragers as agents whose “cognitive landscape” is a probabilistic belief over space, represented as a **Gaussian Process (GP)** with an evolving posterior mean (expected value) and posterior uncertainty (what remains unknown). Decisions follow an OFT-inspired utility rule that balances exploitation and exploration. In doing so, we recast classic foraging problems as sequential decision-making under uncertainty and provide a formal mechanism for (i) the emergence of persistent home ranges and settlement-like intensification, (ii) disequilibrium dynamics under depletion and environmental change, and (iii) the generation of biased archaeological visibility and discovery patterns. The project aims to contribute a rigorous bridge between normative theory, spatial cognition, and generative archaeological modeling—one that is computationally tractable and empirically consequential.

---

## 1. Why this is needed
OFT remains attractive in archaeology because it offers a compact, testable language for connecting environment to behavior. When deployed in spatial settings—patch choice, central place foraging, and travel-cost tradeoffs—it can yield predictions about mobility, settlement distributions, and the use of landscapes. However, many archaeological contexts expose a persistent tension: the logic of “optimality” often presumes that the agent effectively knows the payoff landscape (or knows the probability structure of encountering resources). The archaeological record, by contrast, is built out of histories in which knowledge is acquired unevenly, mistakes are made, and “discovery” is not merely a modern sampling issue but a behavioral process in the past.

This creates a conceptual gap. We can make sophisticated suitability maps, cost-distance models, and visibility analyses, yet these often treat cognition implicitly: the environment becomes a proxy for what people knew, rather than a hypothesis about how knowledge was formed. Meanwhile, approaches that explicitly discuss cognition can struggle to formalize learning and uncertainty without leaning heavily on detailed observational data that rarely exist at the spatial and temporal scales we care about.

The approach proposed here is designed to close this gap by making **knowledge a state variable**. We do not assume that the landscape is fully known. Instead, we model how it becomes known through experience, how uncertainty persists, and how behavior changes as uncertainty collapses or becomes stale. This perspective keeps the explanatory advantages of OFT while aligning the model with archaeological realities: partial knowledge, exploration, and the long-term accumulation of familiarity.

---

## 2. Intellectual foundations (in plain terms)
### 2.1 From OFT to learning problems
OFT provides a normative baseline: foragers behave *as if* they maximize returns subject to constraints. Classic patch models and patch-leaving logic are powerful because they identify the conditions under which leaving, staying, and switching are sensible choices. The challenge is that “returns” are often treated as known.

Once we admit that returns are uncertain, optimality is no longer simply about choosing the best-known option; it becomes about managing a tradeoff between immediate gain and reducing uncertainty for future decisions. This is not a minor tweak. It changes the structure of the problem from a static optimization to a dynamic learning process.

### 2.2 Spatial cognition as probabilistic generalization
Humans (and many animals) do not learn a landscape point-by-point without generalizing. We infer from experience: if one valley is productive, a nearby valley might also be productive; if a ridge is dangerous, nearby ridges may share hazards. In other words, cognition is spatially structured.

A probabilistic model is especially useful here because it makes ignorance visible. It distinguishes “I believe this place is low value” from “I have no idea what is there.” Archaeological arguments often rely on this distinction verbally—familiar territories versus unknown frontiers—but rarely make it operational.

### 2.3 Why Gaussian Processes are a natural cognitive representation
A GP provides two surfaces over space:
- a **posterior mean**: the agent’s current best estimate of landscape value,
- a **posterior uncertainty**: where the agent is confident versus unsure.

This is compelling in archaeology because it yields interpretable levers:
- the kernel length-scale corresponds to how broadly experience generalizes (a cognitive or cultural parameter),
- observation noise corresponds to imperfect perception or noisy cues,
- bounded memory or sparse representations correspond to cognitive constraints.

Most importantly, the GP is not simply a statistical convenience. It makes a claim: spatial cognition behaves as structured inference under uncertainty.

### 2.4 Archaeological spatial proxies, reframed
GIS-derived variables—visibility, cost distance, slope, proximity to water—are often used as proxies for decision-making. A key insight in archaeological theory is that these variables have different relationships to cognition: some constrain what can be perceived, some correlate with familiarity, and some are non-causal correlates. 

Our proposal does not discard proxy thinking; it modernizes it. Proxies are not taken as “the cognition.” Instead:
- visibility-like constructs can define the observation process (what information an agent can acquire),
- cost-distance can shape prior uncertainty (farther regions are less known),
- risk surfaces can appear in utility as genuine constraints.

This yields a model where the same GIS constructs become components in a coherent generative system rather than being interpreted post hoc.

### 2.5 Dynamic equilibrium and disequilibrium as belief–world mismatch
Dynamic equilibrium approaches to carrying capacity and settlement change emphasize feedback loops and instability. In modern terms, a powerful and underused mechanism for disequilibrium is **belief lag**: when the environment changes, learned knowledge becomes stale. People continue to exploit based on outdated expectations, producing overshoot, delayed migration, or aggregation that amplifies vulnerability.

This fits archaeology well. Many large-scale settlement changes appear “too abrupt” to be explained by smooth diminishing returns alone. A belief-state model can generate abrupt shifts from slow underlying change: as long as beliefs remain consistent with experience, behavior stabilizes; when mismatch accumulates, reorganization can be rapid.

---

## 3. The core idea: cognitive landscapes as posteriors
At the center of the approach is a simple distinction:

- The world has a latent “true” landscape of values (resources, suitability, yield, safety, etc.).
- The agent has a learned and uncertain representation of that landscape.

Formally, the agent maintains a belief over space, expressed as a posterior distribution. Practically, the agent carries two maps—expected value and uncertainty—and updates them as it moves.

This permits a clean definition of “discovery” in the past: discovery is not just an archaeologist finding a site; it is a forager reducing uncertainty through experience. In turn, discovery becomes a driver of behavior. The forager explores because it does not know; it settles because it learns; it migrates because the world changes or because it learns of better alternatives.

---

## 4. A publishable argument: three claims, three decisive experiments
This project is organized around three claims that are conceptually simple, empirically consequential, and computationally testable.

### Claim 1: Belief convergence produces intensification and home-range formation without hard-coded “settlement rules.”
In a stationary landscape, a forager with GP cognition will initially explore because uncertainty is high. Over time, uncertainty collapses in the regions it visits. The agent then preferentially exploits areas where it is both confident and rewarded. This creates path dependence: familiarity becomes a self-reinforcing attractor.

The claim is not that the agent always becomes sedentary. Rather, the claim is that the *tendency toward intensification*—repeated use of a region and the emergence of bounded home ranges—can arise naturally from learning dynamics alone. This offers an elegant explanation for why persistent use of places may occur even before invoking social institutions, territoriality, or explicit settlement preferences.

**Decisive Experiment 1 (Equilibrium / Stationary World):**
Simulate a static resource landscape. Compare a GP-cognition forager to baseline agents (random walk, myopic greedy, simple memory). Evaluate whether the GP agent exhibits:
- rapid early exploration,
- uncertainty collapse in visited regions,
- emergence of stable, bounded visitation clusters.

The expected signature is a recognizable two-phase trajectory: exploration first, then localized exploitation. If this signature does not appear, the approach fails at the most basic level.

---

### Claim 2: Disequilibrium emerges when the world changes faster than beliefs update—producing cycles, overshoot, and migration fronts.
Archaeological theory has long wrestled with the fact that environmental change and resource depletion need not produce smooth behavioral responses. A belief-state model provides a concrete mechanism: people act on beliefs, and beliefs are updated through limited experience. If exploitation depletes resources, or if external shifts change the payoff field, then beliefs can lag behind reality.

This lag is not merely noise. It creates systematic misallocation: overuse of formerly good patches, delayed movement away from degrading zones, and abrupt reorganization when accumulated mismatch forces exploration.

The claim is that even minimal ecological feedback—depletion and regeneration—combined with bounded belief updates can generate the kinds of non-linear dynamics that older “dynamic equilibrium” frameworks anticipated but could not compute in detail.

**Decisive Experiment 2 (Dynamic Equilibrium / World Pushback):**
Enable depletion and regeneration so that the landscape changes through use. Evaluate whether:
- localized intensification gives way to patch decline,
- agents re-explore and relocate,
- the system exhibits cycling between exploitation and exploration,
- abrupt transitions appear when belief–world mismatch crosses thresholds.

A particularly telling output is the divergence between the agent’s belief mean in a region and the region’s current truth value. That divergence operationalizes disequilibrium.

---

### Claim 3: Archaeological visibility and discovery bias can be generated endogenously as a function of behavior and cognition.
Archaeological datasets rarely observe “true” past behavior; they observe a biased sample shaped by site formation, preservation, survey strategies, and modern access. The typical response is to treat this as a methodological nuisance.

This project argues that visibility bias is more interesting than that. If people’s mobility and intensification are products of belief dynamics, then the distribution of traces (sites, artifacts, features) is already shaped by cognition. When we add an observation model—what becomes visible to archaeologists—we can produce synthetic records that reflect the joint effects of behavior and sampling.

The claim is that we can identify conditions under which conventional predictive modeling will succeed versus fail, not because the models are “good” or “bad,” but because the record they are fitted to is generated by a process that may systematically obscure the true decision logic.

**Decisive Experiment 3 (Record Formation / Discovery Bias):**
Add a simple archaeological observation layer:
- traces accumulate proportional to time spent (intensification),
- detectability varies by terrain/visibility/access,
- surveys sample imperfectly.

Then ask whether standard correlational predictive models recover the true drivers of behavior. We expect regimes where predictive models look strong but are systematically wrong about mechanism, as well as regimes where they fail despite behavior being strongly patterned.

---

## 5. Model sketch (intentionally minimal, theoretically legible)
The implementation is deliberately kept simple so the theoretical claims remain readable.

1. The world contains a latent resource field over a raster grid.
2. Each agent maintains a GP belief over that field.
3. At each step, the agent observes locally with noise.
4. The agent updates the GP (bounded memory or sparse approximation).
5. The agent moves by maximizing an OFT-inspired utility with an uncertainty bonus:
   - expected value encourages exploitation,
   - uncertainty bonus encourages exploration,
   - cost and risk terms can be added as constraints.

This structure is important. It ensures that the model is not “a black box ABM.” It is a formal instantiation of a simple idea: OFT under learned uncertainty.

---

## 6. Novelty and creativity (what a researcher should find interesting)
This approach is novel not because it uses modern machine learning, but because it uses probabilistic inference to revisit long-standing theoretical questions in archaeology.

1. **It makes cognition measurable.** Knowledge is no longer implicit; it is represented as posterior precision over space.
2. **It turns uncertainty into a causal engine.** Exploration is not an error term; it is a motivated behavior with clear signatures.
3. **It operationalizes disequilibrium.** Dynamic equilibrium becomes computable through belief–world mismatch.
4. **It builds a bridge between GIS proxies and decision theory.** Spatial variables become parts of observation and utility rather than stand-ins for cognition.
5. **It sets up inference.** Once the model produces generative patterns, it becomes possible to ask which parameter regimes are compatible with observed archaeological patterning.

---

## 7. Roadmap: from position paper to program of research
The project is designed to proceed in phases that each yield publishable outcomes.

### Phase 1: Stationary landscapes and emergent home ranges
Deliver a compact demonstration that belief-driven foragers produce exploration-to-exploitation dynamics and spatial intensification patterns that baselines do not.

### Phase 2: Depletion/regeneration and disequilibrium signatures
Show how minimal ecological feedback yields cycling, migration fronts, and abrupt reorganization through belief lag.

### Phase 3: Spatial constraints and proxy integration
Introduce cost-distance, risk, and observation constraints as components of the belief-update and decision rule. Demonstrate corridor formation and route persistence as emergent outcomes.

### Phase 4: Record formation and discovery bias
Generate synthetic archaeological datasets and evaluate when predictive models succeed or mislead. This phase directly connects method to archaeological practice.

### Phase 5: Emulation and inference
Use GP emulation across parameter space and likelihood-free inference to ask what cognitive regimes are identifiable from spatial patterning.

---

## 8. Predictions and falsifiers
A central advantage of casting archaeological foraging as belief-state decision-making is that it yields predictions that are both intuitive and measurable. For **Claim 1 (equilibrium/home-range formation)**, the model predicts a consistent two-phase dynamic in stationary environments: early exploration when uncertainty is high, followed by intensification when uncertainty collapses locally. In outputs, this should appear as (i) a declining uncertainty signal over time in visited regions, (ii) an increasing revisitation rate, and (iii) a bounded visitation footprint that stabilizes even when no explicit “settlement rule” exists. The strongest comparative prediction is that these signatures should be substantially sharper for GP-cognition agents than for myopic or purely reactive baselines under the same observation noise.

The most important falsifier for Claim 1 is the absence of a qualitative regime shift: if GP agents do not show a robust transition from exploration to localized exploitation across a broad range of parameters (noise, memory limits, exploration weight), or if their visitation statistics are indistinguishable from simple heuristics, then the GP belief-state is not contributing explanatory power. For **Claim 2 (disequilibrium)**, the model predicts that introducing depletion/regeneration or exogenous landscape change will produce systematic belief–world mismatch and non-linear behavior such as relocation waves, cycling between exploitation and exploration, or abrupt reorganization after periods of apparent stability. A falsifier here is simple: if ecological feedback or change does not generate measurable belief lag (e.g., divergence between belief mean and truth in exploited regions) and does not cause qualitatively different mobility/settlement dynamics relative to the stationary case, then the proposed disequilibrium mechanism is not operating.

For **Claim 3 (archaeological observability and discovery bias)**, the prediction is that adding even a minimal observation/visibility layer will systematically distort the relationship between true behavioral drivers and the patterns that a researcher can “see” in the synthetic record—creating conditions under which correlational predictive models may look strong while misidentifying mechanism, or may fail despite strongly structured behavior. The falsifier is again direct: if reasonable observation models do not materially change inference outcomes (e.g., predictive modeling recovers the true drivers and parameter regimes reliably across visibility/survey conditions), then “discovery bias” is not being generated endogenously in a way that matters for interpretation.

---

## 9. What would count as success (and what would count as failure)
Success does not require matching a specific archaeological case at the outset. Success requires that the model produces robust, interpretable signatures that meaningfully differ from classic baselines and that align with archaeological intuitions about learning, familiarity, and change.

The approach fails if:
- uncertainty does not meaningfully influence behavior,
- outcomes are indistinguishable from simple heuristics across broad parameter regimes,
- or computational demands prevent systematic exploration.

A key design goal is therefore computational tractability through bounded belief updates and sparse representations—constraints that can be defended as cognitively plausible.

---

## 10. Closing perspective Closing perspective
Archaeology has long been a discipline where theory outruns data and where methods can become detached from mechanism. The goal of this project is to bring these closer together by supplying a formal, generative model of how knowledge and movement co-produce the patterns we observe. By treating the landscape not as a fixed input to optimization but as a partially known world that becomes known through time, we preserve the explanatory power of OFT while addressing the reality of discovery, uncertainty, and disequilibrium.

This is, at its core, a claim about how to do theory in archaeology: not by choosing between quantitative rigor and interpretive nuance, but by building models that make the nuance computable.

