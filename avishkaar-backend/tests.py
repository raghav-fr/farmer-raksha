# from selenium import webdriver
# from selenium.webdriver.common.by import By
# from selenium.webdriver.support.ui import WebDriverWait, Select
# from selenium.webdriver.support import expected_conditions as EC
# from webdriver_manager.chrome import ChromeDriverManager
# from selenium.webdriver.chrome.service import Service

# options = webdriver.ChromeOptions()
# options.add_argument("--headless")
# options.add_argument("--no-sandbox")
# options.add_argument("--disable-dev-shm-usage")

# driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()), options=options)
# driver.get("https://agmarknet.gov.in/")

# # Wait until the dropdown appears
# wait = WebDriverWait(driver, 15)
# state_dropdown = wait.until(EC.presence_of_element_located((By.ID, "ddlState")))

# # Select state
# Select(state_dropdown).select_by_visible_text("Odisha")

# # Wait for district dropdown to populate
# district_dropdown = wait.until(EC.presence_of_element_located((By.ID, "ddlDistrict")))

# # Print available options for debugging
# options = [o.text for o in district_dropdown.find_elements(By.TAG_NAME, "option")]
# print("Available districts:", options)

# # Try matching with available options
# Select(district_dropdown).select_by_visible_text("Bhubaneswar")  # ensure exact match


from dotenv import load_dotenv
import google.generativeai as genai
import os

load_dotenv() # ⬅️ Call the function to load the variables

api = os.getenv("GEMINI_API_KEY")
genai.configure(api_key=api)

model = genai.GenerativeModel("gemini-2.5-flash")
resp = model.generate_content("Hello!")
print(api)
print(resp.text)
