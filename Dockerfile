FROM python:3.12-alpine AS builder

WORKDIR /app

COPY requirements.txt .

RUN apk add --no-cache gcc  musl-dev libffi-dev

RUN pip install --no-cache-dir --user  -r requirements.txt




FROM python:3.12-alpine 

WORKDIR /app

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

COPY --from=builder /root/.local  /home/appuser/.local

COPY /app ./app

USER appuser

ENV PATH=/home/appuser/.local/bin:$PATH \ 
	 PYTHONUNBUFFERED=1

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
 CMD python -c "import urllib.request; urllib-request.urlopen('http://local:8080/health')" || exit 1

CMD ["uvicorn", "app.main:app" , "--host", "0.0.0.0" , "--port", "8080"] 



