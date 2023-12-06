# Online Lasso Container

### Build

Build the container with the following command:

```bash
cd devenv_online_lasso
docker build --pull --rm -f "Dockerfile" -t dolasso:latest "."
```

### Run

Run the container with the following command:

```bash
docker run -it --rm dolasso:latest
```