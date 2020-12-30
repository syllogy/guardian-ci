# Jobs

## go-component

An example `docker-compose.yml` to stand up rabbit and postgres for component tests
```
version: '3'

services:
  rabbit:
    image: rabbitmq:management
    ports:
      - ${RABBIT_PORT:-5672}:5672
      - ${RABBIT_MGMT_PORT:-15672}:15672

  postgres:
    image: postgres
    ports:
      - ${POSTGRES_PORT:-5437}:5432
    environment:
      - POSTGRES_USER=${POSTGRES_USER:-component_default}
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD:-component_default}
      - POSTGRES_DB=${POSTGRES_DB:-component_default}

  migrate:
    build: ./migrations/
    environment:
      - FLYWAY_URL=jdbc:postgresql://postgres:${POSTGRES_PORT:-5437}/${POSTGRES_DB:-component_default}
      - FLYWAY_USER=${POSTGRES_USER:-component_default}
      - FLYWAY_PASSWORD=${POSTGRES_PASSWORD:-component_default}
      - FLYWAY_CONNECT_RETRIES=5
    depends_on:
      - postgres
```


Easily author and add [Parameterized Jobs](https://circleci.com/docs/2.0/reusing-config/#authoring-parameterized-jobs) to the `src/jobs` directory.

Each _YAML_ file within this directory will be treated as an orb job, with a name which matches its filename.

Jobs may invoke orb commands and other steps to fully automate tasks with minimal user configuration.

View the included _[hello.yml](./hello.yml)_ example.


```yaml
  # What will this job do?
  # Descriptions should be short, simple, and clear.
  Sample description
executor: default
parameters:
  greeting:
    type: string
    default: "Hello"
    description: "Select a proper greeting"
steps:
  - greet:
      greeting: << parameters.greeting >>
```

## See:
 - [Orb Author Intro](https://circleci.com/docs/2.0/orb-author-intro/#section=configuration)
 - [How To Author Commands](https://circleci.com/docs/2.0/reusing-config/#authoring-parameterized-jobs)
 - [Node Orb "test" Job](https://github.com/CircleCI-Public/node-orb/blob/master/src/jobs/test.yml)