FROM java:8
EXPOSE 8888
ADD /target/bootcamp-0.0.1-SNAPSHOT.jar bootcamp-0.0.1-SNAPSHOT.jar

ENTRYPOINT ["java", "-jar", "bootcamp-0.0.1-SNAPSHOT.jar"]
