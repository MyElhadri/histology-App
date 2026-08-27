using MailKit.Net.Smtp;
using MailKit.Security;
using MimeKit;
using Microsoft.Extensions.Logging;

namespace HistoClassAI.Api.Services;

public interface IEmailService
{
    Task SendEmailAsync(string toEmail, string subject, string body);
}

public class EmailService : IEmailService
{
    private readonly IConfiguration _configuration;
    private readonly ILogger<EmailService> _logger;

    public EmailService(IConfiguration configuration, ILogger<EmailService> logger)
    {
        _configuration = configuration;
        _logger = logger;
    }

    public async Task SendEmailAsync(string toEmail, string subject, string body)
    {
        var smtpSettings = _configuration.GetSection("SmtpSettings");

        var host = smtpSettings["Host"];
        var portStr = smtpSettings["Port"];
        var username = smtpSettings["Username"];
        var password = smtpSettings["Password"];
        var senderName = smtpSettings["SenderName"] ?? "HistoClassAI";
        var senderEmail = smtpSettings["SenderEmail"] ?? username;

        // ── Diagnostic : afficher les valeurs lues (masquer le mot de passe) ──
        _logger.LogInformation(
            "[EMAIL-DIAG] Configuration lue => Host={Host}, Port={Port}, Username={Username}, Password={PasswordPreview}, SenderEmail={SenderEmail}",
            host ?? "(null)",
            portStr ?? "(null)",
            username ?? "(null)",
            string.IsNullOrWhiteSpace(password) ? "(VIDE!)" : $"{password[..3]}***({password.Length} chars)",
            senderEmail ?? "(null)");

        if (string.IsNullOrWhiteSpace(host) || string.IsNullOrWhiteSpace(username))
        {
            _logger.LogError("[EMAIL-DIAG] ÉCHEC : Host ou Username est vide/null. Vérifiez appsettings.");
            throw new InvalidOperationException("Paramètres SMTP non configurés.");
        }

        if (string.IsNullOrWhiteSpace(password))
        {
            _logger.LogError("[EMAIL-DIAG] ÉCHEC : Le mot de passe SMTP est vide/null !");
            throw new InvalidOperationException("Mot de passe SMTP non configuré.");
        }

        int port = int.TryParse(portStr, out var p) ? p : 587;

        var email = new MimeMessage();
        email.From.Add(new MailboxAddress(senderName, senderEmail!));
        email.To.Add(new MailboxAddress("", toEmail));
        email.Subject = subject;

        var bodyBuilder = new BodyBuilder { HtmlBody = body };
        email.Body = bodyBuilder.ToMessageBody();

        using var client = new SmtpClient();

        // Timeout de 30 secondes (le DNS dans Docker peut être lent)
        client.Timeout = 30000;

        try
        {
            // ── Étape 1 : Connexion ──
            // Gmail exige STARTTLS sur le port 587, SSL implicite sur 465
            var socketOption = port == 465 ? SecureSocketOptions.SslOnConnect : SecureSocketOptions.StartTls;
            _logger.LogInformation("[EMAIL-DIAG] Étape 1/4 : ConnectAsync({Host}, {Port}, {Option})...", host, port, socketOption);
            await client.ConnectAsync(host, port, socketOption);
            _logger.LogInformation("[EMAIL-DIAG] Étape 1/4 : Connexion réussie ✓");

            // ── Étape 2 : Authentification ──
            _logger.LogInformation("[EMAIL-DIAG] Étape 2/4 : AuthenticateAsync({Username})...", username);
            await client.AuthenticateAsync(username, password);
            _logger.LogInformation("[EMAIL-DIAG] Étape 2/4 : Authentification réussie ✓");

            // ── Étape 3 : Envoi ──
            _logger.LogInformation("[EMAIL-DIAG] Étape 3/4 : SendAsync vers {ToEmail}...", toEmail);
            await client.SendAsync(email);
            _logger.LogInformation("[EMAIL-DIAG] Étape 3/4 : Envoi réussi ✓");

            // ── Étape 4 : Déconnexion ──
            _logger.LogInformation("[EMAIL-DIAG] Étape 4/4 : DisconnectAsync...");
            await client.DisconnectAsync(true);
            _logger.LogInformation("[EMAIL-DIAG] Étape 4/4 : Déconnexion réussie ✓");

            _logger.LogInformation("[EMAIL-DIAG] ══ EMAIL ENVOYÉ AVEC SUCCÈS à {ToEmail} ══", toEmail);
        }
        catch (AuthenticationException authEx)
        {
            _logger.LogError(authEx, 
                "[EMAIL-DIAG] ══ ÉCHEC ÉTAPE AUTHENTIFICATION ══ Google a refusé les identifiants. " +
                "Vérifiez : 1) Le mot de passe d'application Google, 2) Que la double authentification est activée sur le compte Google. " +
                "Message exact : {Message}", authEx.Message);
            throw;
        }
        catch (SslHandshakeException sslEx)
        {
            _logger.LogError(sslEx,
                "[EMAIL-DIAG] ══ ÉCHEC ÉTAPE SSL/TLS ══ Le handshake TLS a échoué. " +
                "Vérifiez que le port {Port} correspond bien à l'option {Option}. " +
                "Message exact : {Message}", port, port == 465 ? "SslOnConnect" : "StartTls", sslEx.Message);
            throw;
        }
        catch (SmtpCommandException smtpEx)
        {
            _logger.LogError(smtpEx,
                "[EMAIL-DIAG] ══ ÉCHEC COMMANDE SMTP ══ StatusCode={StatusCode}, Message={Message}",
                smtpEx.StatusCode, smtpEx.Message);
            throw;
        }
        catch (SmtpProtocolException protoEx)
        {
            _logger.LogError(protoEx,
                "[EMAIL-DIAG] ══ ÉCHEC PROTOCOLE SMTP ══ Message={Message}", protoEx.Message);
            throw;
        }
        catch (TimeoutException timeoutEx)
        {
            _logger.LogError(timeoutEx,
                "[EMAIL-DIAG] ══ TIMEOUT ══ Le serveur n'a pas répondu dans les 30 secondes. " +
                "Le conteneur Docker peut-il joindre smtp.gmail.com:587 ? Message : {Message}", timeoutEx.Message);
            throw;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex,
                "[EMAIL-DIAG] ══ ERREUR INATTENDUE ══ Type={ExType}, Message={Message}, StackTrace={Stack}",
                ex.GetType().FullName, ex.Message, ex.StackTrace);
            throw;
        }
    }
}
