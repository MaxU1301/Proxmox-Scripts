helm upgrade --cleanup-on-fail \
  jupyterhub jupyterhub/jupyterhub \
  --namespace default \
  --version=3.3.7 \
  --timeout 10m0s \
  --values config.yaml