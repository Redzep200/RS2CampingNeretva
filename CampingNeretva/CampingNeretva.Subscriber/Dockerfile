FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY CampingNeretva.Subscriber/CampingNeretva.Subscriber.csproj ./CampingNeretva.Subscriber/
COPY CampingNeretva.Model/CampingNeretva.Model.csproj ./CampingNeretva.Model/
COPY CampingNeretva.Service/CampingNeretva.Service.csproj ./CampingNeretva.Service/
RUN dotnet restore CampingNeretva.Subscriber/CampingNeretva.Subscriber.csproj
COPY . .
WORKDIR /src/CampingNeretva.Subscriber
RUN dotnet build CampingNeretva.Subscriber.csproj -c Release -o /app/build

FROM build AS publish
RUN dotnet publish CampingNeretva.Subscriber.csproj -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "CampingNeretva.Subscriber.dll"]