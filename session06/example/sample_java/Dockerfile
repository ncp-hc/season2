# docker build --tag java-docker:src .
# docker run -p 8080:8080 java-docker:src
FROM openjdk:11
WORKDIR /app

COPY .mvn/ .mvn
COPY mvnw pom.xml ./
RUN ./mvnw dependency:go-offline

COPY src ./src

CMD ["./mvnw", "spring-boot:run"]