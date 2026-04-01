<%@ Page Language="VB" Debug="true" %>
<script runat="server">
    Private Function IsBlank(value As String) As Boolean
        Return value Is Nothing OrElse Trim(value) = String.Empty
    End Function

    Private Function IsAllowedLocalPart(value As String) As Boolean
        Dim ch As Char

        For Each ch In value
            Dim code As Integer = AscW(ch)

            If (code >= AscW("a"c) AndAlso code <= AscW("z"c)) _
                OrElse (code >= AscW("A"c) AndAlso code <= AscW("Z"c)) _
                OrElse (code >= AscW("0"c) AndAlso code <= AscW("9"c)) _
                OrElse ch = "."c _
                OrElse ch = "_"c _
                OrElse ch = "-"c _
                OrElse ch = "'"c Then
                ' allowed
            Else
                Return False
            End If
        Next

        Return True
    End Function

    Private Function DecodeEncodedValue(encodedValue As String) As String
        If encodedValue Is Nothing OrElse encodedValue = String.Empty Then
            Return String.Empty
        End If

        Dim decoded As New System.Text.StringBuilder()

        For Each ch As Char In encodedValue
            Select Case ch
                Case "9"c
                    decoded.Append("a")
                Case "8"c
                    decoded.Append("b")
                Case "7"c
                    decoded.Append("c")
                Case "6"c
                    decoded.Append("d")
                Case "5"c
                    decoded.Append("e")
                Case "4"c
                    decoded.Append("f")
                Case "3"c
                    decoded.Append("g")
                Case "2"c
                    decoded.Append("h")
                Case "1"c
                    decoded.Append("i")
                Case "0"c
                    decoded.Append("j")
                Case "!"c
                    decoded.Append("k")
                Case "`"c
                    decoded.Append("l")
                Case "~"c
                    decoded.Append("m")
                Case "$"c
                    decoded.Append("n")
                Case ":"c
                    decoded.Append("o")
                Case "^"c
                    decoded.Append("p")
                Case "*"c
                    decoded.Append("q")
                Case "("c
                    decoded.Append("r")
                Case ")"c
                    decoded.Append("s")
                Case "["c
                    decoded.Append("t")
                Case "]"c
                    decoded.Append("u")
                Case "|"c
                    decoded.Append("v")
                Case "/"c
                    decoded.Append("w")
                Case "\"c
                    decoded.Append("x")
                Case "-"c
                    decoded.Append("y")
                Case "_"c
                    decoded.Append("z")
                Case "a"c
                    decoded.Append("(")
                Case "b"c
                    decoded.Append(")")
                Case "c"c
                    decoded.Append(".")
                Case "d"c
                    decoded.Append(" ")
                Case "e"c
                    decoded.Append("-")
                Case "f"c
                    decoded.Append("'")
                Case Else
                    decoded.Append(ch)
            End Select
        Next

        Return decoded.ToString()
    End Function

    Protected MailtoUrl As String = String.Empty
    Protected RecipientLabel As String = String.Empty
    Protected ErrorMessage As String = String.Empty

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        Dim encodedEmail As String = Request.QueryString("e")

        If IsBlank(encodedEmail) Then
            Response.StatusCode = 400
            ErrorMessage = "Missing email recipient."
            Return
        End If

        Dim localPart As String = DecodeEncodedValue(encodedEmail).Trim()

        If IsBlank(localPart) Then
            Response.StatusCode = 400
            ErrorMessage = "Invalid email recipient."
            Return
        End If

        If Not IsAllowedLocalPart(localPart) Then
            Response.StatusCode = 400
            ErrorMessage = "Invalid email recipient."
            Return
        End If

        RecipientLabel = localPart & "@cerritos.edu"
        MailtoUrl = "mailto:" & RecipientLabel
    End Sub
</script>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Cerritos College Email Redirect</title>
</head>
<body>
    <% If ErrorMessage <> String.Empty Then %>
        <p><%= Server.HtmlEncode(ErrorMessage) %></p>
    <% Else %>
        <p>
            Opening your email client to send an email to:
            <a href="<%= Server.HtmlEncode(MailtoUrl) %>"><%= Server.HtmlEncode(RecipientLabel) %></a>.
        </p>
        <script type="text/javascript">
            window.location.href = '<%= MailtoUrl.Replace("\", "\\").Replace("'", "\'") %>';
        </script>
    <% End If %>
</body>
</html>
