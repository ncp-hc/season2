# docker build --tag java-docker:jar .
# docker run -p 8080:8080 java-docker:jar
FROM openjdk:11
VOLUME /tmp

ARG JAR_FILE=../sample_java/target/waypoint-0.0.1-SNAPSHOT.jar
COPY ${JAR_FILE} app.jar

ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/app.jar"]