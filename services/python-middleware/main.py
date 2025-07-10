from fastapi import FastAPI, Request, HTTPException
import importlib
import os
import glob

app = FastAPI()
FUNCTIONS_PATH = "functions"

@app.post("/run/{func_name}")
async def run_function(func_name: str, request: Request):
    data = await request.json()
    try:
        module_path = f"{FUNCTIONS_PATH}.{func_name}"
        module = importlib.import_module(module_path)
        result = module.run(data)
        return result
    except ModuleNotFoundError:
        raise HTTPException(status_code=404, detail=f"Function '{func_name}' not found")
    except AttributeError:
        raise HTTPException(status_code=500, detail=f"Function '{func_name}' must define a 'run(data)' method")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/")
def list_available_functions():
    files = glob.glob(os.path.join(FUNCTIONS_PATH, "*.py"))
    return {
        "functions": [os.path.splitext(os.path.basename(f))[0] for f in files if not f.endswith("__init__.py")]
    }