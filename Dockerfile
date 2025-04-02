# Use the official Locust image as the base image
FROM locustio/locust

# Copy your Locust test script into the container
COPY locustfile.py /mnt/locust/

# Set the working directory
WORKDIR /mnt/locust

# (Optional) Expose Locust's default port (this is mostly for documentation; Docker uses EXPOSE to inform users)
EXPOSE 8089