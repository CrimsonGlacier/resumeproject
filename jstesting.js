fetch('https://pagecounterfunction.azurewebsites.net/api/GetPageViewCount?')
    .then((res) => res.json())
    .then((data) => {
    viewcount  = `${JSON.stringify(data.PageCounte.Count)}`;
	console.log(data.PageCounte.Count);

var header=document.getElementById("VisitorID");
//document.querySelector("h1").insertAdjacentHTML('beforeEnd',data.PageCounte.Count)
document.querySelector("div").append("data.PageCounte.Count")
//header.innerHTML=data.PageCounte.Count
})