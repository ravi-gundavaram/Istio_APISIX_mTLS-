# Use an official Python runtime as a parent image
FROM python:3.12-slim

# Set the working directory in the container
WORKDIR /usr/src/app

# Argument to determine the service
ARG SERVICE_NAME

# Copy the requirements file to the working directory
COPY ${SERVICE_NAME}/requirements.txt ./

# Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code to the working directory
COPY ${SERVICE_NAME}/ .

# Expose port 80
EXPOSE 80

# Define environment variable for Flask
ENV FLASK_APP=app.py

# Run the application
CMD ["python", "-m", "flask", "run", "--host=0.0.0.0", "--port=80"]
# CMD ["flask", "run", "--host=0.0.0.0", "--port=80"]
