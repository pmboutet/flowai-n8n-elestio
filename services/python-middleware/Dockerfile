FROM python:3.11-slim

WORKDIR /app

# Only install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Create directories
RUN mkdir -p /app/functions /app/shared

# Copy application files
COPY main.py .
COPY functions/ ./functions/

# Run the FastAPI app
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]