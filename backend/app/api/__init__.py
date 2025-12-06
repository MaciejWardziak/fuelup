import pkgutil
import importlib
from fastapi import APIRouter

api_router = APIRouter()

# Automatyczne skanowanie folderu api/
package = __path__  # folder app/api/

for module_info in pkgutil.iter_modules(package):
    module_name = module_info.name

    # Pomijamy plik __init__
    if module_name.startswith("__"):
        continue

    module = importlib.import_module(f"{__name__}.{module_name}")

    # Jeśli moduł ma zdefiniowany `router`, to go dodajemy
    router = getattr(module, "router", None)
    if router:
        api_router.include_router(router)

__all__ = ["api_router"]
