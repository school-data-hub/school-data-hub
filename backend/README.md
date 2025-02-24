## School Data Hub - Backend

This backend is written in python and uses Flask / APIFlask as a framework.

### Setup a local environment

Recommended: set up a virtual environment and activate it before you start!

1. Install dependencies with `pip install -r requirements.txt`
2. Uncomment these lines if you want to create an admin account: https://github.com/school-data-hub/school-data-hub/blob/main/backend/app.py#L139-L153 **username**: `ADM`, **password:** `admin`. **Make sure you change the password or use a different account if you use this in production!!**
3. Use `flask run --reload` in the command line.
4. **That's it!** You should now be able to call http://127.0.0.1:5000/rapidoc and use the endpoints.

