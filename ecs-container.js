{
  "family": "edlab-jupyterhub",
  "containerDefinitions": [
    {
      "name": "edlab-jupyterhub",
      "image": "edlab-jupyterhub-dev",
      "cpu": "512",
      "memory": "2048",
      "entryPoint": [],
      "environment": [],
      "command": [
        "ipython notebook --ip=0.0.0.0 --no-browser"
      ],
      "portMappings": [
        {
          "hostPort": "80",
          "containerPort": "80"
        }
      ],
      "links": [],
      "mountPoints": [
        {
          "sourceVolume": "global-notebooks",
          "containerPath": "/opt/shared_nbs",
          "readOnly": false
        }
      ],
      "essential": true
    }
  ],
  "volumes": [
    {
      "name": "global-notebooks",
      "host": {}
    }
  ]
}
