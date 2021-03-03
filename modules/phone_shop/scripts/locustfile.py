from locust import HttpUser, task, between
class LambdaWorkshop(HttpUser):
    wait_time = between(1, 2.5)
    def on_start(self):
        """ on_start is called when a Locust start before
            any task is scheduled
        """
    @task(1)
    def iphone_gold(self):
        self.client.post("/order", data={"phoneType":"iPhone", "Quantity":"1", "CustomerType":"Gold"})
    @task(2)
    def iphone_platinum(self):
        self.client.post("/order", data={"phoneType":"iPhone", "Quantity":"1", "CustomerType":"Platinum"})
    @task(4)
    def iphone_silver(self):
        self.client.post("/order", data={"phoneType":"iPhone", "Quantity":"1", "CustomerType":"Silver"})
    @task(4)
    def smasung_gold(self):
        self.client.post("/order", data={"phoneType":"Samsung", "Quantity":"1", "CustomerType":"Gold"})