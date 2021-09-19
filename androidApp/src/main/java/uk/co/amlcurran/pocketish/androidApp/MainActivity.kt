package uk.co.amlcurran.pocketish.androidApp

import android.content.Intent
import android.net.Uri
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.view.LayoutInflater
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.material.Card
import androidx.compose.material.CircularProgressIndicator
import androidx.compose.material.MaterialTheme
import androidx.compose.material.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.ComposeView
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.lifecycle.lifecycleScope
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.launch
import uk.co.amlcurran.pocketish.androidApp.databinding.ActivityMainBinding
import uk.co.amlcurran.pocketish.shared.*

fun greet(): String {
    return Greeting().greeting()
}

class MainActivity : AppCompatActivity() {

    private val pocketApi = PocketApi()
    private val userStore = SharedPreferencesUserStore(this)
    private val viewModel = LoginViewModel(pocketApi, DefaultUrlLauncher(this), userStore)
    private val tagsViewModel = MainScreenViewModel(pocketApi, TagsFromArticlesRepository(pocketApi, userStore), userStore)
    private lateinit var binding: ActivityMainBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(LayoutInflater.from(this))
        setContentView(binding.root)

        val launchedFresh = savedInstanceState == null && intent.data.toString() != redirectUrl
        lifecycleScope.launch {
            viewModel.start(launchedFresh) {
                tagsViewModel.getTagsState(ignoreCache = false)
            }
        }
        lifecycleScope.launchWhenStarted {
            tagsViewModel.state.collectInto(binding.mainCompose) { result ->
                MainView(result)
            }
        }
    }

}

suspend fun <T> Flow<AsyncResult<T>>.collectInto(foo: ComposeView, main: @Composable (T) -> Unit) {
    collect { result ->
        result.handle(
            onData = { tagsState ->
                foo.setContent {
                    MaterialTheme {
                        main(tagsState)
                    }
                }
            },
            onLoading = {
                foo.setContent {
                    MaterialTheme {
                        Loading()
                    }
                }
            },
            onError = {  }
        )
    }
}

@Composable
private fun MainView(tagsState: MainViewState) {
    LazyColumn {
        items(1) {
            LatestUntagged(tagsState.latestUntagged)
        }
        items(tagsState.tags) { tag ->
            TagItem(tag)
        }
    }
}

@Composable
private fun TagItem(tag: Tag) {
    Row {
        Text(tag.name)
    }
}

@Composable
private fun LatestUntagged(articles: List<Article>) {
    LazyRow {
        items(articles) { article ->
            Card(modifier = Modifier
                .widthIn(max = 200.dp)
                .padding(16.dp)) {
                Column {
                    Text(article.title, maxLines = 3)
                    Text(article.url, maxLines = 1)
                }
            }
        }
    }
}

@Composable
@Preview
fun Loading() {
    Row(horizontalArrangement = Arrangement.Center,
        verticalAlignment = Alignment.CenterVertically) {
        CircularProgressIndicator(
            Modifier.wrapContentSize()
        )
    }
}

class DefaultUrlLauncher(private val activity: AppCompatActivity) : URLLauncher {
    override fun launch(url: String) {
        activity.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(url)))
    }

}

