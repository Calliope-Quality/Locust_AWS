from locust import HttpUser, task, between

class WebsiteUser(HttpUser):
    # Set your target URL here
    host = "URL"  # Replace with your actual target URL
    wait_time = between(1, 3)

    @task
    def index(self):
        # This sends a GET request to the root endpoint of your target URL.
        self.client.get("/")