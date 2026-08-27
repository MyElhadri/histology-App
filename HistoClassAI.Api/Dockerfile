FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

COPY ["HistoClassAI.Api/HistoClassAI.Api.csproj", "HistoClassAI.Api/"]
RUN dotnet restore "HistoClassAI.Api/HistoClassAI.Api.csproj"

COPY . .
WORKDIR "/src/HistoClassAI.Api"
RUN dotnet build "HistoClassAI.Api.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "HistoClassAI.Api.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final
WORKDIR /app
EXPOSE 8080
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "HistoClassAI.Api.dll"]
