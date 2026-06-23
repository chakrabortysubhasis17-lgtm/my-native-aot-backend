# Stage 1: Install build dependencies and compile native binary
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
RUN apt-get update && apt-get install -y clang zlib1g-dev
WORKDIR /src

COPY ["MyNativeAotApp.csproj", "./"]
RUN dotnet restore

COPY . .
RUN dotnet publish -c Release -r linux-x64 -o /app /p:PublishAot=true

# Stage 2: Ultra-lightweight runtime container
FROM mcr.microsoft.com/dotnet/runtime-deps:8.0-chiseled AS final
WORKDIR /app
COPY --from=build /app .
EXPOSE 8080
ENV ASPNETCORE_HTTP_PORTS=8080
ENTRYPOINT ["./MyNativeAotApp"]