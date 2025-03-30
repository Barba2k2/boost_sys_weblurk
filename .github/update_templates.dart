import 'dart:convert';
import 'dart:io';

void main() async {
  // Informações do repositório
  const owner = 'Barba2k2'; // Nome do dono do repositório
  const repoName = 'templates'; // Nome do repositório
  const pathToFolder = '.github/ISSUE_TEMPLATE'; // Caminho da subpasta

  // Diretório de trabalho
  final currentDirectory = Directory.current.path;
  final githubFolderPath = '$currentDirectory/.github';
  final folderPath = '$currentDirectory/$pathToFolder';

  try {
    // Verifica e remove a pasta .github, se existir
    await _removeExistingFolder(githubFolderPath);

    // Cria a pasta .github
    await Directory(githubFolderPath).create(recursive: true);
    print('📂 Pastas criadas com sucesso!');

    // Baixa os arquivos de .github e ISSUE_TEMPLATE
    await _downloadFolderContents(owner, repoName, githubFolderPath, '.github');
    await _downloadFolderContents(owner, repoName, folderPath, pathToFolder);
  } catch (e) {
    print('⚠️ Ocorreu um erro: $e');
  }
  print('✅ Templates atualizados com sucesso!');
}

/// Função para remover uma pasta existente, se ela existir.
Future<void> _removeExistingFolder(String folderPath) async {
  final folder = Directory(folderPath);
  if (await folder.exists()) {
    await folder.delete(recursive: true);
    print('🗑️  Pasta existente removida!');
  }
}

/// Função para baixar os arquivos de uma pasta no repositório GitHub
Future<void> _downloadFolderContents(String owner, String repoName,
    String localFolderPath, String githubFolderPath) async {
  final apiUrl =
      'https://api.github.com/repos/$owner/$repoName/contents/$githubFolderPath';
  final client = HttpClient();
  final request = await client.getUrl(Uri.parse(apiUrl));
  final response = await request.close();

  if (response.statusCode == 200) {
    final responseBody = await response.transform(utf8.decoder).join();
    final data = jsonDecode(responseBody);

    if (data is List) {
      await _downloadFilesFromData(data, localFolderPath);
    } else {
      print(
          '❌ A pasta $githubFolderPath está vazia ou a estrutura foi diferente do esperado.');
    }
  } else {
    print(
        '❌ Erro ao acessar a pasta $githubFolderPath: ${response.statusCode}');
  }
}

/// Função para baixar os arquivos da lista de dados
Future<void> _downloadFilesFromData(List data, String localFolderPath) async {
  final client = HttpClient();
  for (var item in data) {
    if (item['type'] == 'file') {
      final fileUrl = item['download_url'];
      final fileName = item['name'];
      final filePath = '$localFolderPath/$fileName';

      await _downloadFile(client, fileUrl, filePath, fileName);
    }
  }
}

/// Função para baixar e salvar um arquivo
Future<void> _downloadFile(
    HttpClient client, String fileUrl, String filePath, String fileName) async {
  try {
    final fileRequest = await client.getUrl(Uri.parse(fileUrl));
    final fileResponse = await fileRequest.close();

    if (fileResponse.statusCode == 200) {
      final fileBytes = await fileResponse.fold<List<int>>([],
          (List<int> previous, List<int> element) => previous..addAll(element));
      final fileOut = File(filePath);

      // Cria as pastas se não existirem
      await fileOut.create(recursive: true);
      await fileOut.writeAsBytes(fileBytes);

      // print('⬇️  Arquivo $fileName baixado com sucesso!');
    } else {
      print(
          '❌ Erro ao baixar o arquivo $fileName. Status: ${fileResponse.statusCode}');
    }
  } catch (e) {
    print('⚠️ Erro ao baixar o arquivo $fileName: $e');
  }
}
