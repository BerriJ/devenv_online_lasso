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

### Save and load

Save the container with the following command:

```bash
docker save -o dolasso_latest.tar dolasso:latest
```

Then copy to destination and load with:

```bash
docker load -i PATH/TO/IMAGE/IMAGE.tar
```
