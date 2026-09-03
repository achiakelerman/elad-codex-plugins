#!/usr/bin/env python3
"""Validate a generic ELAD Dynamics Orchestrator project context."""

import json
import sys

ALLOWED_TASK_TYPES = {"plugin-csharp", "javascript-webresource", "configuration", "mixed"}
ALLOWED_QA_MODES = {"playwright", "manual"}
ALLOWED_MODEL_PROFILES = {"balanced", "economy", "quality"}
BASE_REQUIRED = [
    ("projectName",),
    ("workspace", "codePath"),
    ("workspace", "githubRemoteUrl"),
    ("ado", "organizationUrl"),
    ("ado", "project"),
    ("ado", "repository"),
    ("ado", "defaultBranch"),
    ("ado", "baseRemote"),
    ("ado", "triggerTag"),
    ("ado", "doneTag"),
    ("dataverse", "environmentUrl"),
    ("dataverse", "solutionUniqueName"),
    ("dataverse", "publisherPrefix"),
    ("qa", "mode"),
    ("qa", "baseAppUrl"),
    ("workflow", "enabledTaskTypes"),
    ("workflow", "executionMode"),
    ("workflow", "deletionPolicy"),
    ("modelPolicy", "profile"),
    ("modelPolicy", "routingMode"),
]


def get_value(data, path):
    value = data
    for key in path:
        if not isinstance(value, dict) or key not in value:
            return None
        value = value[key]
    return value


def is_empty(value):
    return value is None or value == "" or value == []


def main():
    if len(sys.argv) != 2:
        print("usage: validate_project_context.py <project-context.json>")
        return 2

    try:
        with open(sys.argv[1], "r", encoding="utf-8") as context_file:
            data = json.load(context_file)
    except (OSError, json.JSONDecodeError) as error:
        print(json.dumps({"ok": False, "errors": [str(error)]}, ensure_ascii=False, indent=2))
        return 1

    missing = [".".join(path) for path in BASE_REQUIRED if is_empty(get_value(data, path))]
    errors = []
    task_types = get_value(data, ("workflow", "enabledTaskTypes")) or []

    if not isinstance(task_types, list) or not set(task_types).issubset(ALLOWED_TASK_TYPES):
        errors.append("workflow.enabledTaskTypes must contain only supported task types")
    if "plugin-csharp" in task_types or "mixed" in task_types:
        if is_empty(get_value(data, ("deployment", "pluginProjectPath"))):
            missing.append("deployment.pluginProjectPath")
    if "javascript-webresource" in task_types or "mixed" in task_types:
        if is_empty(get_value(data, ("deployment", "webResourceRoot"))):
            missing.append("deployment.webResourceRoot")
    if get_value(data, ("dataverse", "environmentType")) != "development":
        errors.append("dataverse.environmentType must be development")
    if get_value(data, ("qa", "mode")) not in ALLOWED_QA_MODES:
        errors.append("qa.mode must be playwright or manual")
    if get_value(data, ("workflow", "executionMode")) != "automatic":
        errors.append("workflow.executionMode must be automatic")
    if get_value(data, ("modelPolicy", "profile")) not in ALLOWED_MODEL_PROFILES:
        errors.append("modelPolicy.profile must be balanced, economy, or quality")
    if get_value(data, ("security", "allowProduction")) is not False:
        errors.append("security.allowProduction must be false")
    if get_value(data, ("workflow", "deletionPolicy")) != "deny":
        errors.append("workflow.deletionPolicy must be deny")
    if get_value(data, ("workflow", "requireLocalValidationBeforeCloud")) is not True:
        errors.append("workflow.requireLocalValidationBeforeCloud must be true")
    if get_value(data, ("workflow", "requireQaBeforeGithubPush")) is not True:
        errors.append("workflow.requireQaBeforeGithubPush must be true")

    report = {
        "ok": not missing and not errors,
        "missing": sorted(set(missing)),
        "errors": errors,
        "status": data.get("status", "unknown"),
    }
    print(json.dumps(report, ensure_ascii=False, indent=2))
    return 0 if report["ok"] else 1


if __name__ == "__main__":
    sys.exit(main())
