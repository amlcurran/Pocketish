package uk.co.amlcurran.pocketish.androidApp

import android.content.Intent
import android.net.Uri
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.util.Log
import android.widget.TextView
import androidx.lifecycle.lifecycleScope
import kotlinx.coroutines.launch
import uk.co.amlcurran.pocketish.shared.*

fun greet(): String {
    return Greeting().greeting()
}

class MainActivity : AppCompatActivity() {

    private val pocketApi = PocketApi()
    private val userStore = SharedPreferencesUserStore(this)
    private val viewModel = LoginViewModel(pocketApi, DefaultUrlLauncher(this), userStore)
    private val tagsViewModel = MainScreenViewModel(pocketApi, TagsFromArticlesRepository(pocketApi, userStore), userStore)

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        val tv: TextView = findViewById(R.id.text_view)
        tv.text = greet()

        val launchedFresh = savedInstanceState == null && intent.data.toString() != redirectUrl
        lifecycleScope.launch {
            viewModel.start(launchedFresh, ::loadTags)
        }
    }

    private suspend fun loadTags() {
        val tagsState = tagsViewModel.getTagsState(false)
        val tags = tagsState.tags
        Log.d("TAG", tags.joinToString(separator = " ") { it.name + it.numberOfArticles })
        val latestUntagged = tagsState.latestUntagged
        Log.d("TAG", latestUntagged.joinToString(separator = " ") { it.title + it.url })
    }
}

class DefaultUrlLauncher(private val activity: AppCompatActivity) : URLLauncher {
    override fun launch(url: String) {
        activity.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(url)))
    }

}

