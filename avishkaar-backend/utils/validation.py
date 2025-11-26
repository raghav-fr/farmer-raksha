# utils/validation.py
from typing import Dict, Any, List, Optional

def validate_required_fields(tool_name: str, args: Dict[str, Any], validation_schema: List[Dict[str, Any]]) -> List[str]:
    """
    validation_schema: list of {"name": "<tool>", "parameters": {"required": [...]}}
    Returns list of missing field names (strings), empty if all present.
    """
    schema = None
    for s in validation_schema:
        if s.get("name") == tool_name:
            schema = s
            break
    if not schema:
        return []

    required = schema.get("parameters", {}).get("required", []) or []
    missing = []
    for r in required:
        # consider also present but empty string as missing
        if r not in args or args.get(r) is None or (isinstance(args.get(r), str) and args.get(r).strip() == ""):
            missing.append(r)
    return missing
