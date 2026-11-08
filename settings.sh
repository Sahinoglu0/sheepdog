#!/bin/bash
# Model settings for the kit. launch.sh reads this file for every new session.
#
# Role      | Job                                       | Uses a model?
# Sheepdog  | Manages sessions, asks you for decisions  | yes, but set in .claude/agents/sheepdog.md (model:, effort:)
# worker    | Does the card, writes result and evidence | yes
# reviewer  | Checks the job was really done            | yes
# verifier  | Runs the card's checks                    | yes
# merger    | Runs the tests and lands the branch       | yes
# watchdog, board, dry run                              | NO, spends no model tokens or limit
#
# Model aliases: opus, sonnet, haiku. Effort: low, medium, high.
# Profiles are suggestions; cost and success are not measured.
# Changes apply only to sessions started afterwards.
# Put only plain assignments and comments in this file: it is sourced as shell.

# 1) Pick a profile: frugal (default) | balanced | strong
#    Every role is a separate Claude session, so a single card costs several sessions. The default is the
#    cheapest profile on purpose; raise it only for hard jobs.
PROFILE=frugal

case "$PROFILE" in
  balanced)  # a middle path
    MODEL_WORKER=sonnet;   EFFORT_WORKER=high
    MODEL_REVIEWER=sonnet; EFFORT_REVIEWER=high
    MODEL_VERIFIER=sonnet; EFFORT_VERIFIER=medium
    MODEL_MERGER=sonnet;   EFFORT_MERGER=high ;;
  strong)    # complex code, hard review
    MODEL_WORKER=opus;     EFFORT_WORKER=high
    MODEL_REVIEWER=opus;   EFFORT_REVIEWER=high
    MODEL_VERIFIER=sonnet; EFFORT_VERIFIER=high
    MODEL_MERGER=opus;     EFFORT_MERGER=high ;;
  *)         # frugal (default): narrow scope, clear definition of done
    MODEL_WORKER=sonnet;   EFFORT_WORKER=medium
    MODEL_REVIEWER=sonnet; EFFORT_REVIEWER=medium
    MODEL_VERIFIER=haiku;  EFFORT_VERIFIER=medium
    MODEL_MERGER=sonnet;   EFFORT_MERGER=medium ;;
esac

# 2) Override a single role regardless of profile (remove the leading #):
# MODEL_WORKER=opus
# EFFORT_VERIFIER=low

# 3) For one job's worker, add these lines to the card (other roles are unaffected):
#    Model: opus
#    Effort: high
