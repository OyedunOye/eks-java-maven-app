FROM amazoncorretto:17-alpine-jdk

EXPOSE 8080

COPY ./target/java-maven-app-*.jar /usr/app/
WORKDIR /usr/app

#ENTRYPOINT ["java", "-jar", "java-maven-app-1.0-SNAPSHOT.jar"]
# Replaced with CMD which means command run in shell where regex can be evaluated
CMD java -jar java-maven-*.jar